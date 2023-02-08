RSpec.describe MetadataPresenter::PageWarning do
  subject(:page_warning) do
    described_class.new(page:, main_flow_uuids:)
  end

  describe '#show_warning?' do
    let(:page) { double(uuid: 'some-uuid') }
    let(:main_flow_uuids) { %w[some-uuid] }

    context 'when page is presenter in the service' do
      it 'should return false' do
        expect(page_warning.show_warning?).to be_falsey
      end
    end

    context 'when page is missing from service' do
      let(:page) { nil }

      it 'should return true' do
        expect(page_warning.show_warning?).to be_truthy
      end
    end

    context 'when page is in the main flow' do
      it 'should return false' do
        expect(page_warning.show_warning?).to be_falsey
      end
    end

    context 'when page is not in the main flow' do
      let(:main_flow_uuids) { %w[some-other-page-uuid] }

      it 'should return true' do
        expect(page_warning.show_warning?).to be_truthy
      end
    end
  end
end
