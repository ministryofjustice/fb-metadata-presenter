RSpec.describe MetadataPresenter::EmailValidator do
  subject(:validator) do
    described_class.new(page_answers:, component:)
  end
  let(:component) { page.components.first }
  let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

  describe '#valid?' do
    let(:page) { service.find_page_by_url('/email-address') }

    before do
      validator.valid?
    end

    context 'when is a valid email' do
      %w[
        hi@gmail.com
        empress.wu@digital.justice.gov.uk
        Hedy.Lamarr@justice.gov.uk
        email@subdomain.example.com
        ching+shih@example.com
        email@123.123.123.123
        email@[123.123.123.123]
        "email"@example.com
        1234567890@example.com
        LucyHicksAnderson@example-one.com
        _______@example.com
        email@example.name
        gabriela-brimmer@outlook.com
        dede_mirabal@hotmail.com
        firstname+lastname@example.com
      ].each do |valid_answer|
        let(:answers) { { 'email-address_email_1' => valid_answer } }

        it "returns valid for '#{valid_answer}'" do
          expect(validator).to be_valid
        end
      end
    end

    context 'when is not a valid email' do
      [
        "'hello@gmail.com'",
        'first.last@sub.do,com',
        'first.last',
        'gabriela.brimmer@-xample.com',
        '"first"last"@gmail.org',
        'plainaddress',
        '#@%^%#$@#$@#.com',
        '@example.com',
        'Joe Smith <email@example.com>',
        'email.example.com',
        'email@example@example.com',
        'あいうえお@example.com',
        'email@example.com (Joe Smith)',
        'email@-example.com',
        'email@example..com',
        'empress wu@outlook.com'
      ].each do |invalid_answer|
        let(:answers) { { 'email-address_email_1' => invalid_answer } }
        let(:page) { service.find_page_by_url('/email-address') }

        it "returns invalid for '#{invalid_answer}'" do
          expect(validator).to_not be_valid
        end
      end
    end
  end
end
