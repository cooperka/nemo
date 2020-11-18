# frozen_string_literal: true

class API::V1::ResponseSerializer < ActiveModel::Serializer
  fields :id, :created_at, :updated_at

  # transform UnderscoreTransformer

  association :answers, blueprint: API::V1::AnswerSerializer do |object|
    object.answers.public_access
  end

  field :submitter do |object|
    object.user.name
  end
end
