# frozen_string_literal: true

class PopulateResponseCachedJson < ActiveRecord::Migration[5.2]
  # Disable transaction wrapper so that the update queries will be committed even if we
  # have to fail the transaction part-way through.
  disable_ddl_transaction!

  # rubocop:disable Style/MultilineTernaryOperator
  def up
    responses = Response.where(filters)
    responses = ENV["FORCE_REDO"] ? responses : responses.where(cached_json: nil)
    responses = ENV["IGNORE_MIN_AGO"] ?
      responses.where("updated_at < ?", ENV["IGNORE_MIN_AGO"].to_i.minutes.ago) :
      responses
    cache_responses(responses)
  end
  # rubocop:enable

  # By default with no ENV flags, migrate nothing so the deploy is faster.
  def filters
    if ENV["MIGRATE_ALL"]
      {}
    else
      {
        mission_id: (ENV["MISSIONS"] || "").split.map do |compact_name|
          Mission.find_by(compact_name: compact_name).id
        end,
        form_id: Form.live.map do |form|
          form.id if form.name.match?(/.*/i)
        end.compact
      }
    end
  end

  def cache_responses(responses)
    # Disable logging for this db-heavy migration.
    old_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = 1

    total = responses.count
    start = Time.zone.now
    num_procs = ENV["NUM_PROCS"] ? ENV["NUM_PROCS"].to_i : Etc.nprocessors
    Parallel.each_with_index(responses.find_each, in_processes: num_procs,
                                                  isolation: true) do |response, index|
      puts "Updating #{response.shortcode}... (#{index} / #{total})"
      cache_response(response)
    end
    puts "Elapsed: #{Time.zone.now - start}" if ENV["BENCHMARK"]

    ActiveRecord::Base.logger.level = old_level
  end

  def cache_response(response)
    json = Results::ResponseJsonGenerator.new(response).as_json
    response.update!(cached_json: json)
  rescue StandardError => e
    puts "Failed to update Response #{response.shortcode}"
    puts "  Mission: #{response.mission.name}"
    puts "  Form:    #{response.form.name}"
    puts "  #{e.message}"
  end
end
