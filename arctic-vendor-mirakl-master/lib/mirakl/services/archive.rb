# frozen_string_literal: true

class Mirakl::Services::Archive
  def self.archive_xml(xml_content, shop_id, type = :submitted)
    filename = "archive/#{type}/#{Time.now.to_s(:db)}-#{shop_id}"

    File.new(filename, 'w')

    File.open(filename, 'w') do |file|
      file << xml_content
    end

    filename
  end
end