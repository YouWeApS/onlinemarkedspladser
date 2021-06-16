# frozen_string_literal: true

class VendorLock < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :vendor

  scope :stale, -> { where('created_at < ?', 1.hour.ago) }
end
