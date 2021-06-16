# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each) do |e|
    freeze_at = e.metadata[:freeze]

    if freeze_at
      if freeze_at.is_a?(String) || freeze_at.is_a?(Time)
        Timecop.freeze freeze_at do
          e.run
        end
      else
        Timecop.freeze do
          e.run
        end
      end
    else
      e.run
    end
  end
end
