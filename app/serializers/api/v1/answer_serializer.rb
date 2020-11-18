# frozen_string_literal: true

class API::V1::AnswerSerializer < ActiveModel::Serializer
  fields :id

  # transform UnderscoreTransformer

  # TODO: if scope.params[:controller] == "api/v1/answers" render(x, view: :api)
  # def filter(keys)
  #   keys - (scope.params[:controller] == "api/v1/answers" ? %i[code question] : [])
  # end

  field :code do |object|
    object.question.code
  end

  field :question do |object|
    object.question.name
  end

  field :casted_value, name: :value

  view :api do
    exclude :code, :question
  end
end
