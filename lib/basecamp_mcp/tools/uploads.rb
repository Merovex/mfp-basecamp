# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListUploads < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all uploads (files) in a vault."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          vault_id: { type: "integer", description: "The vault ID" }
        },
        required: %w[project_id vault_id]
      )

      class << self
        def call(project_id:, vault_id:, server_context:)
          uploads = client(server_context:).get_all("buckets/#{project_id}/vaults/#{vault_id}/uploads")
          text_response(uploads)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetUpload < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific upload (file) by ID."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          upload_id: { type: "integer", description: "The upload ID" }
        },
        required: %w[project_id upload_id]
      )

      class << self
        def call(project_id:, upload_id:, server_context:)
          upload = client(server_context:).get("buckets/#{project_id}/uploads/#{upload_id}")
          text_response(upload)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateUpload < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new upload in a vault. Requires an attachable_sgid from create_attachment."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          vault_id: { type: "integer", description: "The vault ID" },
          attachable_sgid: { type: "string", description: "The attachable_sgid from create_attachment" },
          description: { type: "string", description: "File description" },
          base_name: { type: "string", description: "Display name for the file" }
        },
        required: %w[project_id vault_id attachable_sgid]
      )

      class << self
        def call(project_id:, vault_id:, attachable_sgid:, description: nil, base_name: nil, server_context:)
          body = { attachable_sgid: attachable_sgid }
          body[:description] = description if description
          body[:base_name] = base_name if base_name
          upload = client(server_context:).post("buckets/#{project_id}/vaults/#{vault_id}/uploads", body)
          text_response(upload)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UpdateUpload < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update an upload's description or base name."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          upload_id: { type: "integer", description: "The upload ID" },
          description: { type: "string", description: "New description" },
          base_name: { type: "string", description: "New display name" }
        },
        required: %w[project_id upload_id]
      )

      class << self
        def call(project_id:, upload_id:, description: nil, base_name: nil, server_context:)
          body = {}
          body[:description] = description if description
          body[:base_name] = base_name if base_name
          upload = client(server_context:).put("buckets/#{project_id}/uploads/#{upload_id}", body)
          text_response(upload)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class TrashUpload < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Move an upload (file) to the trash."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          upload_id: { type: "integer", description: "The upload ID" }
        },
        required: %w[project_id upload_id]
      )

      class << self
        def call(project_id:, upload_id:, server_context:)
          client(server_context:).trash(project_id, upload_id)
          text_response({ status: "trashed", upload_id: upload_id })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateAttachment < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create an attachment and get an attachable_sgid for use in uploads and rich text content."

      input_schema(
        properties: {
          name: { type: "string", description: "Filename" },
          content_type: { type: "string", description: "MIME type (e.g., image/png, application/pdf)" },
          byte_size: { type: "integer", description: "File size in bytes" },
          checksum: { type: "string", description: "Base64-encoded MD5 checksum of the file" }
        },
        required: %w[name content_type byte_size checksum]
      )

      class << self
        def call(name:, content_type:, byte_size:, checksum:, server_context:)
          body = { name: name, content_type: content_type, byte_size: byte_size, checksum: checksum }
          attachment = client(server_context:).post("attachments", body)
          text_response(attachment)
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
