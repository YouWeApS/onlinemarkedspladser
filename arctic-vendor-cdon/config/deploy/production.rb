# frozen_string_literal: true

server 'cdon.yourdomain.com',
  roles: %i[app],
  primary: true,
  user: 'vendor'
