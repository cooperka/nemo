# frozen_string_literal: true

module ConditionalLogicForm
  # Serializes Questionings for cases where they are targets of conditional logic, like left_qing/right_qing.
  class TargetQuestioningSerializer < ApplicationSerializer
    fields :id, :code, :rank, :full_dotted_rank, :qtype_name, :option_set_id
    field :textual?, name: :textual
    field :numeric?, name: :numeric
  end
end
