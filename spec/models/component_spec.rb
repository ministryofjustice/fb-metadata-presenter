RSpec.describe MetadataPresenter::Component do
  subject(:component) { described_class.new(attributes) }

  describe '#to_partial_path' do
    let(:attributes) { { '_type' => 'email' } }

    it 'returns type' do
      expect(component.to_partial_path).to eq(
        'metadata_presenter/component/email'
      )
    end
  end

  describe '#items' do
    let(:component) do
      service.find_page_by_url('do-you-like-star-wars').components.first
    end

    it 'returns an array of openstruct component item objects' do
      expect(component.items).to be_an(Array)
      expect(component.items.size).to eq(2)
    end

    it 'contains objects that respond to the necessary properties' do
      component.items.each do |item|
        expect(item).to respond_to(:id)
        expect(item).to respond_to(:name)
        expect(item).to respond_to(:description)
      end
    end

    it 'returns an array of Item classes' do
      expect(component.items).to all(be_an(MetadataPresenter::Item))
    end

    context 'when component is an autocomplete type' do
      before do
        allow(component).to receive(:type).and_return('autocomplete')
      end

      it 'contains objects that respond to the necessary properties' do
        component.items.each do |item|
          expect(item).to respond_to(:id)
          expect(item).to respond_to(:name)
        end
      end

      it 'returns an array of AutocompleteItem classes' do
        expect(component.items).to all(be_an(MetadataPresenter::AutocompleteItem))
      end
    end
  end

  describe '#humanised_title' do
    context 'when the component has a label' do
      let(:component) do
        service.find_page_by_url('name').components.first
      end

      it 'returns the label value' do
        expect(component.humanised_title).to eq('Full name')
      end
    end

    context 'when the component has a legend' do
      let(:component) do
        service.find_page_by_url('do-you-like-star-wars').components.first
      end

      it 'returns the legend value' do
        expect(component.humanised_title).to eq('Do you like Star Wars?')
      end
    end
  end

  describe '#content?' do
    context 'when type is content' do
      it 'returns true' do
        component = described_class.new(_type: 'content')
        expect(component.content?).to be_truthy
      end
    end

    context 'when type is not content' do
      it 'returns false' do
        component = described_class.new({})
        expect(component.content?).to be_falsey
      end
    end
  end

  describe '#autocommplete?' do
    context 'when type is autocomplete' do
      it 'returns true' do
        component = described_class.new(_type: 'autocomplete')
        expect(component.autocomplete?).to be_truthy
      end
    end

    context 'when type is not autocomplete' do
      it 'returns false' do
        component = described_class.new({})
        expect(component.content?).to be_falsey
      end
    end
  end

  describe '#find_item_by_uuid' do
    context 'when there are items' do
      let(:attributes) do
        {
          items: [MetadataPresenter::Item.new('_uuid': '123')]
        }
      end

      it 'returns the found item' do
        expect(component.find_item_by_uuid('123')).to eq(attributes[:items].first)
      end
    end

    context 'when there are no items' do
      let(:attributes) do
        {}
      end

      it 'returns nil' do
        expect(component.find_item_by_uuid('123')).to be_nil
      end
    end
  end

  describe '#supports_branching?' do
    context 'when is radio' do
      let(:attributes) { { '_type' => 'radios' } }

      it 'returns true' do
        expect(component.supports_branching?).to be_truthy
      end
    end

    context 'when is checkbox' do
      let(:attributes) { { '_type' => 'checkboxes' } }

      it 'returns true' do
        expect(component.supports_branching?).to be_truthy
      end
    end

    context 'when is file upload' do
      let(:attributes) { { '_type' => 'upload' } }

      it 'returns false' do
        expect(component.supports_branching?).to be_falsey
      end
    end
  end

  describe '#supported_validations' do
    context 'when validation bundle exists for component type' do
      context 'number bundle' do
        let(:attributes) { { '_type' => 'number' } }
        let(:expected_validations) do
          %w[
            exclusive_maximum
            exclusive_minimum
            maximum
            minimum
            multiple_of
          ]
        end

        it 'returns the supported validations for number component type' do
          expect(component.supported_validations).to match_array(expected_validations)
        end
      end

      context 'string bundle' do
        let(:expected_validations) do
          %w[
            min_length
            max_length
            min_word
            max_word
            pattern
            format
          ]
        end

        %w[text textarea].each do |component_type|
          let(:attributes) { { '_type' => component_type } }

          it "returns the supported validations for #{component_type} component type" do
            expect(component.supported_validations).to match_array(expected_validations)
          end
        end
      end

      context 'date bundle' do
        let(:attributes) { { '_type' => 'date' } }
        let(:expected_validations) do
          %w[
            date_after
            date_before
            date_within_last
            date_within_next
          ]
        end

        it 'returns the supported validations for date component type' do
          expect(component.supported_validations).to match_array(expected_validations)
        end
      end
    end

    context 'when validation bundle does not exist for component type' do
      let(:attributes) { { '_type' => 'no-validation-component' } }

      it 'returns an empty array' do
        expect(component.supported_validations).to eq([])
      end
    end
  end
end
