RSpec.describe MetadataPresenter::Flow do
  let(:service_metadata) do
    metadata_fixture(:branching)
  end
  subject(:flow) do
    service.flow('cf6dc32f-502c-4215-8c27-1151a45735bb')
  end

  describe '#branch?' do
    context 'when the type is branch' do
      subject(:flow) do
        service.flow('09e91fd9-7a46-4840-adbc-244d545cfef7')
      end

      it 'returns true' do
        expect(flow).to be_branch
      end
    end

    context 'when the type is not a branch' do
      subject(:flow) do
        service.flow('cf6dc32f-502c-4215-8c27-1151a45735bb')
      end

      it 'returns false' do
        expect(flow).to_not be_branch
      end
    end
  end

  describe '#default_next' do
    context 'when there is a next default' do
      it 'returns the next default page' do
        expect(flow.default_next).to eq(
          '9e1ba77f-f1e5-42f4-b090-437aa9af7f73'
        )
      end
    end

    context 'when there is no next flow' do
      subject(:flow) { service.flow('778e364b-9a7f-4829-8eb2-510e08f156a3') }

      it 'returns nothing' do
        expect(flow.default_next).to eq('')
      end
    end
  end

  describe '#conditions' do
    context 'when there are conditions' do
      subject(:flow) { service.flow('09e91fd9-7a46-4840-adbc-244d545cfef7') }

      it 'returns conditions' do
        expect(flow.conditions).to eq(
          [
            MetadataPresenter::Condition.new(
              {
                "condition_type": 'if',
                "next": 'e8708909-922e-4eaf-87a5-096f7a713fcb',
                "criterias": [
                  {
                    "operator": 'is',
                    "page": '68fbb180-9a2a-48f6-9da6-545e28b8d35a',
                    "component": 'ac41be35-914e-4b22-8683-f5477716b7d4',
                    "field": 'c5571937-9388-4411-b5fa-34ddf9bc4ca0'
                  }
                ]
              }
            )
          ]
        )
      end
    end

    context 'when there are no conditions' do
      it 'returns empty' do
        expect(flow.conditions).to eq([])
      end
    end
  end
end