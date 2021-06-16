# frozen_string_literal: true

# api1
server 'api1.yourdomain.com',
  user: :core_api,
  roles: %i[app db web],
  primary: true

# api2
server 'api2.yourdomain.com',
  user: :core_api,
  roles: %i[app web]
