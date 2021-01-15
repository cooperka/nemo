# frozen_string_literal: true

# Find all existing Paperclip attachments and add ActiveStorage entries for them.
# From https://github.com/thoughtbot/paperclip/blob/master/MIGRATING.md
class ConvertToActiveStorage < ActiveRecord::Migration[6.0]
  require "open-uri"

  def up
    get_blob_id = "LASTVAL()"

    ActiveRecord::Base.connection.raw_connection.prepare("active_storage_blob_statement", <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL

    ActiveRecord::Base.connection.raw_connection.prepare("active_storage_attachment_statement", <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
    SQL

    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    transaction do
      models.each do |model|
        attachment_keys = model.column_names.map do |c|
          Regexp.last_match(1) if c =~ /(.+)_file_size$/
        end.compact

        next if attachment_keys.blank?

        total = model.all.count
        puts "Converting #{total} #{model.name.pluralize}..."

        # TODO: Make this work because it's super slow when running sync.
        #   PG::InvalidSqlStatementName: ERROR:  prepared statement "active_storage_blob_statement" does not exist
        # num_procs = ENV["NUM_PROCS"] ? ENV["NUM_PROCS"].to_i : Etc.nprocessors
        # Parallel.each_with_index(model.find_each.each, in_processes: num_procs) do |instance, index|
        model.find_each.each_with_index do |instance, index|
          attachment_keys.each do |attachment_key|
            if instance.send(attachment_key)&.path.blank?
              puts "Skipping blank #{attachment_key} for #{model.name} #{instance.id}" if ENV["DEBUG"]
              next
            end

            puts "Converting #{model.name} #{attachment_key} #{instance.id} (#{index} / #{total})"

            ActiveRecord::Base.connection.raw_connection.exec_prepared(
              "active_storage_blob_statement", [
                key(instance, attachment_key),
                instance.send("#{attachment_key}_file_name"),
                instance.send("#{attachment_key}_content_type"),
                instance.send("#{attachment_key}_file_size"),
                checksum(instance.send(attachment_key)),
                instance.updated_at.iso8601
              ]
            )

            ActiveRecord::Base.connection.raw_connection.exec_prepared(
              "active_storage_attachment_statement", [
                attachment_key,
                model.name,
                instance.id,
                instance.updated_at.iso8601
              ]
            )
          end
        end
      end
    end
  end

  def down
    # Don't bother deleting the new records
  end

  private

  def key(_instance, _attachment)
    SecureRandom.uuid
    # Alternatively:
    # instance.send("#{attachment}_file_name")
  end

  # Cache something here that's slow?
  # Test with local data to make sure it's fast in that case.
  # Run diagnostics on how many attachments there are
  # CEJP: 400. GW: 275k, 8 GB. Health: 20k. Staging: 1100.
  # Responses + operations + ODK XML
  # Easily fits on disk, can we clone locally first? (just GW/Health)
  def checksum(attachment)
    if Rails.configuration.active_storage.service == :local
      url = attachment.path
      Digest::MD5.base64digest(File.read(url))
    else
      url = attachment.url
      Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
    end
  end
end
