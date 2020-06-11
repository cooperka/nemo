# frozen_string_literal: true

module Results
  # Generates cached JSON for a given response.
  class ResponseJsonGenerator
    include ActionView::Helpers::TextHelper

    attr_accessor :response

    def initialize(response)
      self.response = response
    end

    def as_json
      object = {}
      object["ResponseID"] = response.id
      object["ResponseShortcode"] = response.shortcode
      object["FormName"] = form.name
      object["ResponseSubmitterName"] = user.name
      object["ResponseSubmitDate"] = response.created_at.iso8601
      object["ResponseReviewed"] = response.reviewed?
      root = response.root_node_including_tree(:choices, form_item: :question, option_node: :option_set)
      hash = {}
      # TODO: hash = response_answers()
      save_response_answers(root, hash) unless root.nil?
      object.merge(form_answers(response.form, hash))
    end

    private

    delegate :form, :user, to: :response

    # Saves data for the given Response node to a flat hash for later lookup.
    def save_response_answers(node, hash)
      node.children.each do |child_node|
        if child_node.is_a?(Answer)
          append_answer(hash, child_node.questioning_id, value_for(child_node))
        elsif child_node.is_a?(AnswerSet)
          append_answer(hash, child_node.questioning_id, answer_set_value(child_node))
        elsif child_node.is_a?(AnswerGroup)
          save_response_answers(child_node, hash)
        elsif child_node.is_a?(AnswerGroupSet)
          save_response_answers(child_node, hash)
        end
      end
    end

    # Any answer can theoretically have been repeatable in the past.
    # For each Qing ID, save an array of answers for this Response.
    def append_answer(hash, id, answer)
      # TODO: What if no answers submitted? Make sure all access is moderated.
      # TODO: Nest/group within key of parent repeat code
      (hash[id] ||= []) << answer
    end

    # Make sure we include everything that was specified by our metadata,
    # even if an older Response didn't include a newer qing/group originally
    # (Power BI will fail if any keys are missing).
    def form_answers(node, hash)
      parts = node.children.map do |child|
        if child.is_a?(QingGroup)
          puts "QingGroup, key: #{node_key(child)}"
          value = if child.repeatable?
                    # TODO: This previously recursed as an [array],
                    #   but maybe it needs to be treated differently.
                    # [form_answers(child, hash, repeats: true)]
                    repeat_answers(child, hash)
                  else
                    form_answers(child, hash)
                  end
          {"#{node_key(child)}": value}
        # elsif repeats
        #   puts "Repeats, key: #{node_key(child)}"
        #   {"#{node_key(child)}": hash[child.id]}
        else
          puts "Value, key: #{node_key(child)}"
          {"#{node_key(child)}": hash[child.id]&.first}
        end
      end
      parts.reduce(&:merge)
    end

    # TODO: This should return an array
    def repeat_answers(node, hash)
      key = node_key(node)
      parts = node.children.map do |child|
        # TODO: Handle multiple qings in a single repeat group.
        puts "Repeats"
        {
          "#{repeat_key}": hash[child.id].map do |value|
            puts "Repeat child, key: #{node_key(child)}"
            {"#{node_key(child)}": value}
          end
        }
      end
      parts.reduce(&:merge)
    end

    # X (OO)
    def add_form_answers(node, object, hash, repeats: false)
      node.children.each do |child|
        if child.is_a?(QingGroup)
          add_group_answers(child, object, hash)
        elsif repeats
          # TODO: Handle multiple qings in a single repeat group.
          hash[child.id].each do |value|
            object << {"#{node_key(child)}": value}
          end
        else
          object[node_key(child)] = hash[child.id]&.first
        end
      end
    end

    # X (OO)
    def add_group_answers(group, object, hash)
      if group.repeatable?
        item = object[node_key(group)] = []
        add_form_answers(group, item, hash, repeats: true)
      else
        item = object[node_key(group)] = {}
        add_form_answers(group, item, hash)
      end
    end

    def answer_set_value(answer_set)
      set = {}
      answer_set.children.each do |answer|
        option_node = answer.option_node
        set[option_node.level_name] = answer.option_name if option_node
      end
      set.to_s
    end

    def value_for(answer)
      case answer.qtype_name
      when "date" then answer.date_value
      when "time" then answer.time_value&.to_s(:std_time)
      when "datetime" then answer.datetime_value&.iso8601
      when "integer", "counter" then answer.value&.to_i
      when "decimal" then answer.value&.to_f
      when "select_one" then answer.option_name
      when "select_multiple" then answer.choices.empty? ? nil : answer.choices.map(&:option_name).sort.to_s
      when "location" then answer.attributes.slice("latitude", "longitude", "altitude", "accuracy").to_s
      else format_value(answer.value)
      end
    end

    def format_value(value)
      # Data that's been copied from MS Word contains a bunch of HTML decoration.
      # Get rid of that via simple_format.
      /\A<!--/.match?(value) ? simple_format(value) : value.to_s
    end

    # Returns the OData key for a given group, response node, or form node.
    def node_key(node)
      node.code.vanilla
    end
  end
end
