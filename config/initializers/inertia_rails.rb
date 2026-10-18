# frozen_string_literal: true

InertiaRails.configure do |config|
  # Asset changes (a new Vite build) make the version differ, which forces a full reload.
  config.version = ViteRuby.digest
  config.always_include_errors_hash = true
  config.use_script_element_for_initial_page = true
end
