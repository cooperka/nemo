# frozen_string_literal: true

class API::V1::FormSerializer < ActiveModel::Serializer
  fields :id, :name, :responses_count

  # transform UnderscoreTransformer

  # TODO: if scope.params[:action] == "show" (view: :show)
  # def filter(keys)
  #   # Only show questions if show action.
  #   keys - (scope.params[:action] == "show" ? [] : [:questions])
  # end

  view :show do
    field :questions do |object|
      object.api_visible_questions.as_json(only: %i[id code], methods: :name)
    end
  end
end
