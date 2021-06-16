# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition #:nodoc:
      # Override the timestamps method to add the deleted_at field for use with paranoia
      def timestamps(**options)
        options[:null] = false if options[:null].nil?

        deleted_at_options = options.dup
        deleted_at_options[:null] = true

        column(:created_at, :datetime, options)
        column(:updated_at, :datetime, options)
        column(:deleted_at, :datetime, deleted_at_options)
      end
    end
  end
end

# rubocop:enable Style/ClassAndModuleChildren
