# frozen_string_literal: true

module BasecampMcp
  module Tools
    class GetQuestionnaire < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get the questionnaire (automatic check-ins) for a project."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project ID" },
          questionnaire_id: { type: "integer", description: "The questionnaire ID (from project dock)" }
        },
        required: %w[project_id questionnaire_id]
      )

      class << self
        def call(project_id:, questionnaire_id:, server_context:)
          q = client(server_context:).get("buckets/#{project_id}/questionnaires/#{questionnaire_id}")
          text_response(q)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListQuestions < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all automatic check-in questions in a questionnaire."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          questionnaire_id: { type: "integer", description: "The questionnaire ID" }
        },
        required: %w[project_id questionnaire_id]
      )

      class << self
        def call(project_id:, questionnaire_id:, server_context:)
          questions = client(server_context:).get_all(
            "buckets/#{project_id}/questionnaires/#{questionnaire_id}/questions"
          )
          text_response(questions)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetQuestion < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific automatic check-in question."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          question_id: { type: "integer", description: "The question ID" }
        },
        required: %w[project_id question_id]
      )

      class << self
        def call(project_id:, question_id:, server_context:)
          question = client(server_context:).get("buckets/#{project_id}/questions/#{question_id}")
          text_response(question)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class ListQuestionAnswers < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "List all answers to an automatic check-in question."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          question_id: { type: "integer", description: "The question ID" }
        },
        required: %w[project_id question_id]
      )

      class << self
        def call(project_id:, question_id:, server_context:)
          answers = client(server_context:).get_all(
            "buckets/#{project_id}/questions/#{question_id}/answers"
          )
          answers.each { |a| a["content"] = HtmlUtils.strip_for_ai(a["content"]) if a["content"] }
          text_response(answers)
        rescue => e
          error_response(e.message)
        end
      end
    end

    class GetQuestionAnswer < MCP::Tool
      extend BasecampMcp::ToolHelpers

      description "Get a specific answer to an automatic check-in question."

      input_schema(
        properties: {
          project_id: { type: "integer", description: "The project (bucket) ID" },
          answer_id: { type: "integer", description: "The answer ID" }
        },
        required: %w[project_id answer_id]
      )

      class << self
        def call(project_id:, answer_id:, server_context:)
          answer = client(server_context:).get("buckets/#{project_id}/question_answers/#{answer_id}")
          answer["content"] = HtmlUtils.strip_for_ai(answer["content"]) if answer["content"]
          text_response(answer)
        rescue => e
          error_response(e.message)
        end
      end
    end
  end
end
