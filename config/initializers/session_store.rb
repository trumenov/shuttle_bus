Rails.application.config.session_store :cookie_store, key: "#{ Rails.application.secrets[:app_cookie_prefix] }_ci_app_session", expire_after: 2.years
