RSpec.shared_examples :translated_locale do |key|
  I18n.available_locales.each do |locale|
    context "locale: #{locale}" do
      before { I18n.locale = locale }
      after(:context) { I18n.locale = I18n.default_locale }
      it { expect(I18n.t(key)).not_to include 'translation missing:' }
      it { expect(I18n.t(key)).to be_present }
    end
  end
end
