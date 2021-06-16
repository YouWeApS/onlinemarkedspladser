# frozen_string_literal: true

server 'amazon-co-uk.yourdomain.com',
  roles: %i[app],
  primary: true,
  user: 'vendor'

server 'amazon-de.yourdomain.com',
  roles: %i[app],
  primary: true,
  user: 'vendor'

server 'amazon-es.yourdomain.com',
  roles: %i[app],
  primary: true,
  user: 'vendor'

server 'amazon-fr.yourdomain.com',
  roles: %i[app],
  primary: true,
  user: 'vendor'

server 'amazon-it.yourdomain.com',
  roles: %i[app],
  primary: true,
  user: 'vendor'
