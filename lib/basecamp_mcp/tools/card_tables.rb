# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetCardTable < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get the card table (kanban board) for a project."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project ID" },
          card_table_id: { type: "integer", description: "The card table ID (from project dock, name: kanban_board)" }
        },
        required: %w[project_id card_table_id]
      )

      class << self
        def call(project_id:, card_table_id:, server_context:)
          table = client(server_context:).get("buckets/#{project_id}/card_tables/#{card_table_id}")
          text_response(table)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListCardTableColumns < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all columns in a card table."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_table_id: { type: "integer", description: "The card table ID" }
        },
        required: %w[project_id card_table_id]
      )

      class << self
        def call(project_id:, card_table_id:, server_context:)
          columns = client(server_context:).get_all(
            "buckets/#{project_id}/card_tables/#{card_table_id}/columns"
          )
          text_response(columns)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetCardTableColumn < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific card table column."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          column_id: { type: "integer", description: "The column ID" }
        },
        required: %w[project_id column_id]
      )

      class << self
        def call(project_id:, column_id:, server_context:)
          column = client(server_context:).get("buckets/#{project_id}/card_tables/columns/#{column_id}")
          text_response(column)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateCardTableColumn < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new column in a card table."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_table_id: { type: "integer", description: "The card table ID" },
          title: { type: "string", description: "Column title" }
        },
        required: %w[project_id card_table_id title]
      )

      class << self
        def call(project_id:, card_table_id:, title:, server_context:)
          column = client(server_context:).post(
            "buckets/#{project_id}/card_tables/#{card_table_id}/columns", { title: title }
          )
          text_response(column)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UpdateCardTableColumn < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a card table column's title."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          column_id: { type: "integer", description: "The column ID" },
          title: { type: "string", description: "New column title" }
        },
        required: %w[project_id column_id title]
      )

      class << self
        def call(project_id:, column_id:, title:, server_context:)
          column = client(server_context:).put(
            "buckets/#{project_id}/card_tables/columns/#{column_id}", { title: title }
          )
          text_response(column)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class TrashCardTableColumn < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Trash a card table column."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          column_id: { type: "integer", description: "The column ID" }
        },
        required: %w[project_id column_id]
      )

      class << self
        def call(project_id:, column_id:, server_context:)
          client(server_context:).trash(project_id, column_id)
          text_response({ status: "trashed", column_id: column_id })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListCards < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all cards in a card table column."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          column_id: { type: "integer", description: "The column ID" }
        },
        required: %w[project_id column_id]
      )

      class << self
        def call(project_id:, column_id:, server_context:)
          cards = client(server_context:).get_all(
            "buckets/#{project_id}/card_tables/columns/#{column_id}/cards"
          )
          text_response(cards)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetCard < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific card by ID."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_id: { type: "integer", description: "The card ID" }
        },
        required: %w[project_id card_id]
      )

      class << self
        def call(project_id:, card_id:, server_context:)
          card = client(server_context:).get("buckets/#{project_id}/card_tables/cards/#{card_id}")
          text_response(card)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateCard < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new card in a column."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          column_id: { type: "integer", description: "The column ID" },
          title: { type: "string", description: "Card title" },
          content: { type: "string", description: "Card description (supports HTML)" },
          due_on: { type: "string", description: "Due date (YYYY-MM-DD)" },
          assignee_ids: { type: "array", items: { type: "integer" }, description: "People IDs to assign" }
        },
        required: %w[project_id column_id title]
      )

      class << self
        def call(project_id:, column_id:, title:, content: nil, due_on: nil, assignee_ids: nil, server_context:)
          body = { title: title }
          body[:content] = content if content
          body[:due_on] = due_on if due_on
          body[:assignee_ids] = assignee_ids if assignee_ids
          card = client(server_context:).post(
            "buckets/#{project_id}/card_tables/columns/#{column_id}/cards", body
          )
          text_response(card)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UpdateCard < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Update a card's title, content, due date, or assignees."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_id: { type: "integer", description: "The card ID" },
          title: { type: "string", description: "New title" },
          content: { type: "string", description: "New description (supports HTML)" },
          due_on: { type: "string", description: "New due date (YYYY-MM-DD)" },
          assignee_ids: { type: "array", items: { type: "integer" }, description: "New assignee IDs" }
        },
        required: %w[project_id card_id]
      )

      class << self
        def call(project_id:, card_id:, title: nil, content: nil, due_on: nil, assignee_ids: nil, server_context:)
          body = {}
          body[:title] = title if title
          body[:content] = content if content
          body[:due_on] = due_on unless due_on.nil?
          body[:assignee_ids] = assignee_ids if assignee_ids
          card = client(server_context:).put("buckets/#{project_id}/card_tables/cards/#{card_id}", body)
          text_response(card)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class MoveCard < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Move a card to a different column."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_id: { type: "integer", description: "The card ID" },
          column_id: { type: "integer", description: "The target column ID" }
        },
        required: %w[project_id card_id column_id]
      )

      class << self
        def call(project_id:, card_id:, column_id:, server_context:)
          client(server_context:).post(
            "buckets/#{project_id}/card_tables/cards/#{card_id}/moves",
            { column_id: column_id }
          )
          text_response({ status: "moved", card_id: card_id, column_id: column_id })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class TrashCard < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Move a card to the trash."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_id: { type: "integer", description: "The card ID" }
        },
        required: %w[project_id card_id]
      )

      class << self
        def call(project_id:, card_id:, server_context:)
          client(server_context:).trash(project_id, card_id)
          text_response({ status: "trashed", card_id: card_id })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListCardSteps < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all steps (checklist items) on a card."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_id: { type: "integer", description: "The card ID" }
        },
        required: %w[project_id card_id]
      )

      class << self
        def call(project_id:, card_id:, server_context:)
          steps = client(server_context:).get_all(
            "buckets/#{project_id}/card_tables/cards/#{card_id}/steps"
          )
          text_response(steps)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetCardStep < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific card step (checklist item)."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          step_id: { type: "integer", description: "The step ID" }
        },
        required: %w[project_id step_id]
      )

      class << self
        def call(project_id:, step_id:, server_context:)
          step = client(server_context:).get("buckets/#{project_id}/card_tables/steps/#{step_id}")
          text_response(step)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CreateCardStep < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Create a new step (checklist item) on a card."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          card_id: { type: "integer", description: "The card ID" },
          title: { type: "string", description: "Step title" }
        },
        required: %w[project_id card_id title]
      )

      class << self
        def call(project_id:, card_id:, title:, server_context:)
          step = client(server_context:).post(
            "buckets/#{project_id}/card_tables/cards/#{card_id}/steps", { title: title }
          )
          text_response(step)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class CompleteCardStep < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Mark a card step as complete."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          step_id: { type: "integer", description: "The step ID" }
        },
        required: %w[project_id step_id]
      )

      class << self
        def call(project_id:, step_id:, server_context:)
          client(server_context:).post("buckets/#{project_id}/card_tables/steps/#{step_id}/completion")
          text_response({ status: "completed", step_id: step_id })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class UncompleteCardStep < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Mark a card step as incomplete."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          step_id: { type: "integer", description: "The step ID" }
        },
        required: %w[project_id step_id]
      )

      class << self
        def call(project_id:, step_id:, server_context:)
          client(server_context:).delete("buckets/#{project_id}/card_tables/steps/#{step_id}/completion")
          text_response({ status: "uncompleted", step_id: step_id })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class RepositionCardStep < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Change a card step's position."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          step_id: { type: "integer", description: "The step ID" },
          position: { type: "integer", description: "New position (1-based)" }
        },
        required: %w[project_id step_id position]
      )

      class << self
        def call(project_id:, step_id:, position:, server_context:)
          client(server_context:).put(
            "buckets/#{project_id}/card_tables/steps/#{step_id}/position", { position: position }
          )
          text_response({ status: "repositioned", step_id: step_id, position: position })
        rescue => e
          error_response(e.message)
        end
      end
    end

    class TrashCardStep < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Trash a card step."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          step_id: { type: "integer", description: "The step ID" }
        },
        required: %w[project_id step_id]
      )

      class << self
        def call(project_id:, step_id:, server_context:)
          client(server_context:).trash(project_id, step_id)
          text_response({ status: "trashed", step_id: step_id })
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
