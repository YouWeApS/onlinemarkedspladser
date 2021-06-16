# frozen_string_literal: true

class CDON::Country
  def self.to_name(iso_or_name)
    case iso_or_name.to_s.downcase
    when 'dk', 'denmark' then 'Denmark'
    when 'se', 'sweden'  then 'Sweden'
    when 'no', 'norway'  then 'Norway'
    when 'fi', 'finland' then 'Finland'
    end
  end

  def self.to_iso(iso_or_name)
    case iso_or_name.to_s.downcase
    when 'dk', 'denmark' then 'dk'
    when 'se', 'sweden'  then 'se'
    when 'no', 'norway'  then 'no'
    when 'fi', 'finland' then 'fi'
    end
  end
end
