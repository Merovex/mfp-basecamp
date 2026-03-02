# frozen_string_literal: true

module BasecampMcp
  module Tools
    class ListVaults < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'List vaults (folders) in a project or nested inside another vault (paginated).'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The parent vault ID (from project dock)' },
          page: { type: 'integer', description: 'Page number (default: 1)' }
        },
        required: %w[project_id vault_id]
      )

      class << self
        def call(project_id:, vault_id:, server_context:, page: 1)
          vaults, has_more = client(server_context:).get_page(
            "buckets/#{project_id}/vaults/#{vault_id}/vaults", {}, page: page
          )
          paginated_list_response(vaults, page: page, has_more: has_more)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class GetVault < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Get a specific vault (folder) by ID.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The vault ID' }
        },
        required: %w[project_id vault_id]
      )

      class << self
        def call(project_id:, vault_id:, server_context:)
          vault = client(server_context:).get("buckets/#{project_id}/vaults/#{vault_id}")
          text_response(vault)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class CreateVault < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Create a new vault (folder) inside an existing vault.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The parent vault ID' },
          title: { type: 'string', description: 'Vault/folder name' }
        },
        required: %w[project_id vault_id title]
      )

      class << self
        def call(project_id:, vault_id:, title:, server_context:)
          vault = client(server_context:).post("buckets/#{project_id}/vaults/#{vault_id}/vaults", { title: title })
          text_response(vault)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class UpdateVault < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a vault's title."

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The vault ID' },
          title: { type: 'string', description: 'New vault title' }
        },
        required: %w[project_id vault_id title]
      )

      class << self
        def call(project_id:, vault_id:, title:, server_context:)
          vault = client(server_context:).put("buckets/#{project_id}/vaults/#{vault_id}", { title: title })
          text_response(vault)
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end

    class TrashVault < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description 'Move a vault (folder) to the trash.'

      input_schema(
        properties: {
          project_id: { type: 'integer', description: 'The project (bucket) ID' },
          vault_id: { type: 'integer', description: 'The vault ID' }
        },
        required: %w[project_id vault_id]
      )

      class << self
        def call(project_id:, vault_id:, server_context:)
          client(server_context:).trash(project_id, vault_id)
          text_response({ status: 'trashed', vault_id: vault_id })
        rescue StandardError => e
          error_response(e.message)
        end
      end
    end
  end
end
