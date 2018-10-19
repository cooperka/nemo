module OperationsHelper
  def operations_index_fields
    [].tap do |fields|
      fields.concat %w(details created_at)
      fields << 'creator' if can?(:manage, Operation)
      fields.concat %w(status result actions)
    end
  end

  def operations_index_links(operations)
    [].tap do |links|
      links << link_to(translate_action(Operation, :clear), clear_operations_path, method: :post, data: { confirm: t('operation.clear_confirm') })
    end
  end

  def format_operations_field(operation, field)
    case field
    when 'details'
      link_to(operation.details, operation_path(operation))
    when 'creator'
      link_to(operation.creator.name, user_path(operation.creator))
    when 'created_at'
      t('layout.time_ago', time: time_ago_in_words(operation.created_at))
    when 'status'
      link_to(t("operation.status.#{operation.status}"), operation_path(operation))
    when 'result'
      case operation.status
      when :failed
        link_to(t("operation.see_error_report"), operation_path(operation))
      when :completed
        if operation.attachment.present?
          link_to(t("operation.result_link_text.#{operation.kind}"), download_operation_path(operation))
        end
      end
    when 'actions'
      table_action_links(operation)
    else
      operation.send(field)
    end
  end

  def operations_status
    status = OperationStatus.new(Operation.accessible_by(current_ability).where(creator: current_user))

    if status.total?
      label =
        if status.in_progress?
          if status.completed?
            t("operation.summary.some_completed", completed: status.completed, total: status.total)
          else
            t("operation.summary.all_in_progress", count: status.in_progress)
          end
        else
          t("operation.summary.all_completed", count: status.completed)
        end

      label = t("operation.summary.with_errors", message: label, count: status.failed) if status.failed?

      link_to(icon_tag(:operation) + label, operations_path)
    else
      link_to(icon_tag(:operation) + t("operation.operations_panel"), operations_path)
    end
  end
end
