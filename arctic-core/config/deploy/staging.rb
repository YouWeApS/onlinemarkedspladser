# frozen_string_literal: true

# api1
server 'staging.api.yourdomain.com',
  user: :core_api,
  roles: %i[app db web],
  primary: true
