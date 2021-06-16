# frozen_string_literal: true

Doorkeeper::Application.find_or_create_by \
  name: 'Arctic Merchant UI',
  uid: '22c28fc4-83c8-4fa0-8b7f-02b8993726e0',
  secret: '1388dabe-0d63-4349-8326-da95c72f9002',
  redirect_uri: %w[
    http://localhost:8081/callback
    http://localhost:5000/docs/oauth2-redirect.html
  ],
  scopes: %w[
    user:read
    user:write
    product:read
    product:write
    order:read
    order:write
  ].join(' ')
