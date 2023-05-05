RSpec.describe SavedProgressValidator do
  describe '#valid?' do
    let(:record) { MetadataPresenter::SavedForm.new }

    context 'when is a valid email' do
      %w[
        hi@gmail.com
        empress.wu@digital.justice.gov.uk
        Hedy.Lamarr@justice.gov.uk
        email@subdomain.example.com
        ching+shih@example.com
        email@123.123.123.123
        1234567890@example.com
        LucyHicksAnderson@example-one.com
        _______@example.com
        email@example.name
        gabriela-brimmer@outlook.com
        dede_mirabal@hotmail.com
        firstname+lastname@example.com
      ].each do |valid_answer|
        it "returns valid for '#{valid_answer}'" do
          record.secret_answer = '123'
          record.email = valid_answer
          subject.validate(record)
          expect(record.errors).to be_empty
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
        it "returns invalid for '#{invalid_answer}'" do
          record.secret_answer = '123'
          record.email = invalid_answer
          subject.validate(record)
          expect(record.errors.count).to eq(1)
        end
      end
    end
  end

  describe 'invalid secret answer' do
    let(:record) { MetadataPresenter::SavedForm.new }
    let(:invalid_answer) { SecureRandom.hex(101) }

    it 'cannot be more than 100 characters' do
      record.email = 'valid@email.com'
      record.secret_answer = invalid_answer

      subject.validate(record)
      expect(record.errors.count).to eq(1)
    end
  end
end
