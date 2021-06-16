# frozen_string_literal: true

class VendorShopConfiguration < ApplicationRecord #:nodoc:
  TYPES = %w[VendorShopDispersalConfiguration VendorShopCollectionConfiguration].freeze

  belongs_to :shop
  belongs_to :vendor

  has_one :channel, through: :vendor

  has_many :category_maps, dependent: :destroy
  has_many :shadow_products, dependent: :destroy
  has_many :vendor_product_matches, dependent: :destroy
  has_many :dispersals, dependent: :destroy
  has_many :shipping_configurations, dependent: :destroy
  has_many :import_maps,
    -> { order(position: :asc) },
    foreign_key: :vendor_shop_configuration_id

  delegate :name, to: :vendor

  validates :type,
    presence: true,
    inclusion: { in: TYPES }

  validate :validate_auth_config

  crypt_keeper :auth_config,
    encryptor: :postgres_pgp,
    key: Rails.application.credentials.dig(:crypt_keeper, :secret) || 'secret',
    salt: Rails.application.credentials.dig(:crypt_keeper, :salt) || 'salt'

  scope :enabled, -> { unscope(where: :enabled).where enabled: true }
  scope :disabled, -> { unscope(where: :enabled).where enabled: false }

  def auth_config
    JSON.parse super
  end

  def auth_config=(json)
    super JSON.dump json
  end

  def dispersal?
    type == 'VendorShopDispersalConfiguration'
  end

  def collection?
    !dispersal?
  end

  private

    def validate_auth_config
      JSON::Validator.validate!(channel.auth_config_schema, auth_config)
    rescue JSON::Schema::ValidationError => error
      errors.add :auth_config, error.message
    end
end
