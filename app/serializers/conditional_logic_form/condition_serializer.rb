# frozen_string_literal: true

module ConditionalLogicForm
  # Serializes Condition for use in condition form.
  class ConditionSerializer < ApplicationSerializer
    fields :id, :left_qing_id, :right_qing_id, :right_side_type, :op, :value,
      :option_node_id, :form_id, :conditionable_id, :conditionable_type

    # TODO what does this accomplish?
    # delegate :id, :conditionable_id, :value, to: :object

    field :operator_options do |object|
      object.applicable_operator_names.map { |n| {name: I18n.t("condition.operators.select.#{n}"), id: n} }
    end

    field :option_set_id do |object|
      object.left_qing&.option_set_id
    end
  end
end
