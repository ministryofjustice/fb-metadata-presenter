RSpec.describe MetadataPresenter::Metadata do
  subject(:metadata) { described_class.new(meta, editor:) }

  context 'when editor' do
    let(:editor) { true }

    context 'when no text is in the metadata for a field with default content' do
      let(:meta) { { 'section_heading' => '' } }

      it 'should present the default text' do
        expect(metadata.section_heading).to eq('[Optional section heading]')
      end
    end

    context 'when there is text in the metadata property' do
      let(:meta) { { 'section_heading' => 'some text' } }

      it 'should present back the text' do
        expect(metadata.section_heading).to eq('some text')
      end
    end

    context 'when there is no default text for an empty property' do
      let(:meta) { { 'nope' => '' } }

      it 'should be nil' do
        expect(metadata.nope).to be_nil
      end
    end
  end

  context 'not the editor' do
    let(:editor) { false }

    context 'when no text is in the metadata for a field with default content' do
      let(:meta) { { 'section_heading' => '' } }

      it 'should remain an empty string' do
        expect(metadata.section_heading).to eq('')
      end
    end

    context 'when there is text in the metadata property' do
      let(:meta) { { 'section_heading' => 'some text' } }

      it 'should present back the text' do
        expect(metadata.section_heading).to eq('some text')
      end
    end

    context 'when there is a uuid' do
      let(:meta) { { '_uuid' => 'some awesome uuid' } }

      it 'should present back the text' do
        expect(metadata.uuid).to eq('some awesome uuid')
      end
    end

    context 'when there is no default text for an empty property' do
      let(:meta) { { 'nope' => '' } }

      it 'should be an empty string' do
        expect(metadata.nope).to eq('')
      end
    end
  end

  describe '#editor?' do
    context 'when using the default' do
      subject(:metadata) { described_class.new({}) }

      it 'returns false' do
        expect(metadata.editor?).to be_falsey
      end
    end

    context 'when passing editor true' do
      subject(:metadata) { described_class.new({}, editor: true) }

      it 'returns true' do
        expect(metadata.editor?).to be_truthy
      end
    end
  end
end
