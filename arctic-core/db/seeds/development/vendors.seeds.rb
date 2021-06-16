# frozen_string_literal: true

after 'development:channels' do
  # amazon.co.uk
  FactoryBot.create :vendor,
    id: 'ac2d3139-100a-4011-8ca0-2670fd2ec35b',
    token: '64cf21de-db7a-4370-982a-0d5f14d90c61',
    name: 'UK',
    channel: Channel.find('7804ac6b-41af-4d7f-bcc4-175eee2e1ace'),
    validation_url: 'http://localhost:9292/validate'

  # amazon.de
  FactoryBot.create :vendor,
    id: 'd64fb7fe-c4db-49ed-b1f3-4a38bd7f3bfb',
    token: '6200cd44-94bb-4449-b783-a905fd6895fc',
    name: 'DE',
    channel: Channel.find('7804ac6b-41af-4d7f-bcc4-175eee2e1ace'),
    validation_url: 'http://localhost:9292/validate'

  # amazon.es
  FactoryBot.create :vendor,
    id: '3dfab9cd-9e7b-422b-a4c0-61df3185501e',
    token: '323a0412-220a-4593-bfe7-d5842bfa10d1',
    name: 'ES',
    channel: Channel.find('7804ac6b-41af-4d7f-bcc4-175eee2e1ace'),
    validation_url: 'http://localhost:9293/validate'

  # amazon.fr
  FactoryBot.create :vendor,
    id: '6c3e032f-2016-41a8-b077-e2c50c41df0a',
    token: '62a058a7-642f-4f67-9fbd-573badbc8c7f',
    name: 'FR',
    channel: Channel.find('7804ac6b-41af-4d7f-bcc4-175eee2e1ace'),
    validation_url: 'http://localhost:9293/validate'

  # amazon.it
  FactoryBot.create :vendor,
    id: '551c8297-8c30-4d06-9147-1d9629302f6a',
    token: 'f57ffa26-9c48-496d-83af-9a183267b038',
    name: 'IT',
    channel: Channel.find('7804ac6b-41af-4d7f-bcc4-175eee2e1ace'),
    validation_url: 'http://localhost:9293/validate'

  # Dandomain
  FactoryBot.create :vendor,
    id: '96ebeaa3-7fe4-4c1e-afe7-b76884de891c',
    token: 'f832cd13-50dd-4c72-853e-582f63ab41ea',
    name: 'MyFirstVendor',
    channel: Channel.find('c69e5641-f5b7-47d3-bdef-7a30bfe5b347')

  # CDON
  FactoryBot.create :vendor,
    id: '233dcaf3-4258-4af3-afff-9afdf8fe87c8',
    token: 'a9aa0008-8218-4ddd-af28-58e3b147b1b7',
    name: 'DK',
    channel: Channel.find('c82ba3f5-80e2-4646-8210-5ecea3971d27'),
    validation_url: 'http://localhost:9292/validate',
    sku_formatter: 'AlphaNumSku'
end
