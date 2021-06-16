# frozen_string_literal: true

namespace :vendor_locks do
  desc 'Cleanup stale locks'
  task cleanup: :environment do
    VendorLock.stale.delete_all
  end
end
