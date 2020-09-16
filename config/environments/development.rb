# frozen_string_literal: true

ELMO::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports
  config.consider_all_requests_local = true

  # Caching may need to be turned on when testing caching itself. If so, please use
  # config/initializers/local_config.rb to override this value,
  # or change it here but please don't commit the change!
  config.action_controller.perform_caching = false

  # This is here only in case the above value is overridden as described.
  config.cache_store = :dalli_store, nil, {value_max_bytes: 2.megabytes}

  # care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :letter_opener

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = false
  config.i18n.fallbacks = false

  config.action_view.logger = nil

  # For puma-dev domains.
  # BetterErrors::Middleware.allow_ip!("0.0.0.0/0")
  # BetterErrors.use_pry!

  # e.g. in config/initializers/better_errors.rb
  # This will stop BetterErrors from trying to render larger objects, which can cause
  # slow loading times and browser performance problems. Stated size is in characters and refers
  # to the length of #inspect's payload for the given object. Please be aware that HTML escaping
  # modifies the size of this payload so setting this limit too precisely is not recommended.
  # default value: 100_000
  # BetterErrors.maximum_variable_inspect_size = 5_000_000

  config.to_prepare do
    # # [Performance] Uncomment to profile specific methods.
    # Rack::MiniProfiler.profile_method(User, :foo) { "executing foo" }
    #
    # # Reduce the sample rate if your browser is slow
    # # (default: 0.5 ms; moderate: 5 ms; fast and rough: 10-20 ms).
    # Rack::MiniProfiler.config.flamegraph_sample_rate = 10
  end

  config.after_initialize do
    # # [Performance] Uncomment for automatic n+1 query alerts.
    # Bullet.enable = true
    # Bullet.bullet_logger = true # log/bullet.log
    # Bullet.console = true
    # Bullet.rails_logger = true
  end

  # React development variant (unminified)
  config.react.variant = :development
end
