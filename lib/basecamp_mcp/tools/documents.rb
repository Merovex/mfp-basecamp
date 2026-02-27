# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListDocuments < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List all documents in a vault (folder).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The vault ID' }
        },
        required: %w[project_id vault_id]
      )

      class << self
        def call(project_id:, vault_id:, server_context:)
          docs = client(server_context:).get_all("buckets/#{project_id}/vaults/#{vault_id}/documents")
          docs.each { |d| d['content'] = HtmlUtils.strip_for_ai(d['content']) if d['content'] }
          text_response(docs)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetDocument < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific document by ID.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          document_id: { type: 'integer', description: 'The document ID' }
        },
        required: %w[project_id document_id]
      )

      class << self
        def call(project_id:, document_id:, server_context:)
          doc = client(server_context:).get("buckets/#{project_id}/documents/#{document_id}")
          doc['content'] = HtmlUtils.strip_for_ai(doc['content']) if doc['content']
          text_response(doc)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateDocument < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new document in a vault.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The vault ID' },
          title: { type: 'string', description: 'Document title' },
          content: { type: 'string', description: 'Document body (supports HTML)' },
          status: { type: 'string', enum: %w[active archived], description: 'Document status' }
        },
        required: %w[project_id vault_id title]
      )

      class << self
        def call(project_id:, vault_id:, title:, server_context:, content: nil, status: nil)
          body = { title: title }
          body[:content] = content if content
          body[:status] = status if status
          doc = client(server_context:).post("buckets/#{project_id}/vaults/#{vault_id}/documents", body)
          text_response(doc)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateDocument < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a document's title or content."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          document_id: { type: 'integer', description: 'The document ID' },
          title: { type: 'string', description: 'New title' },
          content: { type: 'string', description: 'New content (supports HTML)' }
        },
        required: %w[project_id document_id]
      )

      class << self
        def call(project_id:, document_id:, server_context:, title: nil, content: nil)
          body = {}
          body[:title] = title if title
          body[:content] = content if content
          doc = client(server_context:).put("buckets/#{project_id}/documents/#{document_id}", body)
          text_response(doc)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashDocument < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a document to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          document_id: { type: 'integer', description: 'The document ID' }
        },
        required: %w[project_id document_id]
      )

      class << self
        def call(project_id:, document_id:, server_context:)
          client(server_context:).trash(project_id, document_id)
          text_response({ status: 'trashed', document_id: document_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
