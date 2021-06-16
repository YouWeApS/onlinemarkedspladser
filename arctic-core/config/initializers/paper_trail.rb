# frozen_string_literal: true

# the following line is required for PaperTrail >= 4.0.0 with Rails
PaperTrail::Rails::Engine.eager_load!

# Defer evaluation in case we're using spring loader (otherwise it would be
# something like "spring app | app | started 13 secs ago | development")
# http://bit.ly/2Q48WmW
Rails.application.configure do
  console do
    PaperTrail.request.whodunnit = lambda {
      @paper_trail_whodunnit ||= begin
        name = nil

        while name.to_s.strip.blank?
          print 'What is your email (used by PaperTrail to record who changed records)? '
          name = "Console(#{gets.chomp})"
        end

        puts "Thank you, #{name}! Have a wonderful time!"

        name
      end
    }
  end
end
