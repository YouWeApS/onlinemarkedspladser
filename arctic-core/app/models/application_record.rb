# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base #:nodoc:
  self.abstract_class = true

  acts_as_paranoid

  has_paper_trail

  def most_recent_changes
    versions.where("object_changes::text not like '{}'::text").last.changeset
  end
end
