# frozen_string_literal: true

class Amazon::Archive
  attr_reader :name, :content, :options

  def initialize(name, content, **options)
    @name = name
    @content = content
    @options = Hashie::Mash.new options
  end

  def path
    File.expand_path relative_path, __dir__
  end

  def filename
    "#{File.basename name, '.xml'}.xml"
  end

  def save
    FileUtils.mkdir_p File.dirname path
    File.write path, content
  end

  private

    def relative_path
      "../../archive/#{subdir}#{filename}"
    end

    def subdir
      options.subdir.present? ? "#{options.subdir}/" : nil
    end
end
