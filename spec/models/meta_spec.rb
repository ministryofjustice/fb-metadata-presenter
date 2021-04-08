RSpec.describe MetadataPresenter::Meta do
  subject(:meta) { described_class.new(metadata) }

  describe '#items' do
    let(:metadata) do
      {
        "_id": "config.meta",
        "_type": "config.meta",
        "items": [
          {
            "_id": "config.meta--link",
            "_type": "link",
            "href": "/cookies",
            "text": "Cookies"
          },
          {
            "_id": "config.meta--link--2",
            "_type": "link",
            "href": "/privacy",
            "text": "Privacy"
          },
          {
            "_id": "config.meta--link--3",
            "_type": "link",
            "href": "/accessibility",
            "text": "Accessibility"
          }
        ]
      }
    end

    it 'returns the an array of meta items' do
      expect(meta.items.size).to be 3
      meta.items.each do |item|
        expect(item).to be_kind_of(MetadataPresenter::MetaItem)
      end
    end
  end
end
