# frozen_string_literal: true

class S3Uploader
  attr_reader :bucket

  def self.sanitize(string)
    string.gsub(/[^0-9A-Za-z]/, '')
  end

  def initialize(bucket)
    @bucket ||= bucket
  end

  def upload(file, **options)
    name = File.basename file
    write file, name, options
    self
  end

  def url_for(file, **options)
    name = File.basename file

    options.reverse_merge! \
      bucket: bucket,
      key: name

    # https://amzn.to/2Eqvn4h
    Aws::S3::Presigner.new.presigned_url :get_object, **options
  end

  private

    def write(file, name, **options)
      s3.bucket(bucket).object(name).upload_file file, **options
    end

    def s3
      @s3 ||= Aws::S3::Resource.new
    end
end
