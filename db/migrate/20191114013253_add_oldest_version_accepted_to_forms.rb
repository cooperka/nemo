# frozen_string_literal: true

class AddOldestVersionAcceptedToForms < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :oldest_version_accepted_id, :uuid
    add_index :forms, :oldest_version_accepted_id
    add_foreign_key :forms, :form_versions, column: :oldest_version_accepted_id

    Form.all.each do |form|
      form.update!(oldest_version_accepted_id: form.current_version.id) if form.current_version
    end
  end
end
