RSpec.describe MetadataPresenter::AuthForm do
  subject { described_class.new(attrs) }

  let(:attrs) do
    { username:, password: }
  end

  describe 'validations' do
    context '`username` and `password` are blank' do
      let(:username) { nil }
      let(:password) { nil }

      it { is_expected.not_to be_valid }

      context 'error types' do
        before { subject.valid? }

        it 'has an error in the `username` field' do
          expect(subject.errors.added?(:username, :blank)).to be(true)
        end

        it 'has an error in the `password` field' do
          expect(subject.errors.added?(:password, :blank)).to be(true)
        end

        it 'does not have errors in the base' do
          expect(subject.errors.added?(:base)).to be(false)
        end
      end
    end

    context '`username` is blank' do
      let(:username) { nil }
      let(:password) { 'password' }

      it { is_expected.not_to be_valid }

      context 'error types' do
        before { subject.valid? }

        it 'has an error in the `username` field' do
          expect(subject.errors.added?(:username, :blank)).to be(true)
        end

        it 'does not have an error in the `password` field' do
          expect(subject.errors.added?(:password)).to be(false)
        end

        it 'does not have errors in the base' do
          expect(subject.errors.added?(:base)).to be(false)
        end
      end
    end

    context '`password` is blank' do
      let(:username) { 'username' }
      let(:password) { nil }

      it { is_expected.not_to be_valid }

      context 'error types' do
        before { subject.valid? }

        it 'has an error in the `password` field' do
          expect(subject.errors.added?(:password, :blank)).to be(true)
        end

        it 'does not have an error in the `username` field' do
          expect(subject.errors.added?(:username)).to be(false)
        end

        it 'does not have errors in the base' do
          expect(subject.errors.added?(:base)).to be(false)
        end
      end
    end

    context '`username` and `password` are entered but wrong' do
      let(:username) { 'username' }
      let(:password) { 'password' }

      it { is_expected.not_to be_valid }

      context 'error types' do
        before { subject.valid? }

        it 'does not have errors in the `username` field' do
          expect(subject.errors.added?(:username)).to be(false)
        end

        it 'does not have errors in the `password` field' do
          expect(subject.errors.added?(:password)).to be(false)
        end

        it 'has errors in the base' do
          expect(subject.errors.added?(:base, :unauthorised)).to be(true)
        end
      end
    end

    context '`username` and `password` are entered and correct' do
      let(:username) { 'username' }
      let(:password) { 'password' }

      before do
        allow(ENV).to receive(:[]).with('BASIC_AUTH_USER').and_return(username)
        allow(ENV).to receive(:[]).with('BASIC_AUTH_PASS').and_return(password)
      end

      it { is_expected.to be_valid }
    end
  end
end
