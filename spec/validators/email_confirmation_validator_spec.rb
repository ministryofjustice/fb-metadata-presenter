RSpec.describe SavedProgressValidator do
  describe '#valid?' do
    let(:record) { MetadataPresenter::EmailConfirmation.new }

    it 'is valid when both attributes match' do
      record.assign_attributes('123', '123')
      expect(record.valid?).to be(true)
    end

    it 'is not valid if the attributes do not match' do
      record.assign_attributes('123', '456')
      expect(record.valid?).to be(false)
    end
  end
end
