RSpec.describe MetadataPresenter::Route do
  subject(:route) do
    described_class.new(service: service, traverse_from: traverse_from, column: column)
  end
  let(:column) { 0 }

  describe '#traverse' do
    let(:metadata) { metadata_fixture(:branching) }
    let(:service) { MetadataPresenter::Service.new(metadata) }
    let(:traverse_from) { service.start_page.uuid }

    context 'when traversing from the start' do
      before do
        route.traverse
      end

      let(:potential_routes) do
        # the remaining number of routes after the 'row zero' route has been traversed
        # for all branches in the metadata
        11
      end
      let(:expected_uuids) do
        # traversing from start page will pick the first conditional at each
        # branch it comes across and go all the way to the confirmation page
        # it will generate a new route object for every other conditional destination
        [
          'cf6dc32f-502c-4215-8c27-1151a45735bb', # Service name goes here
          '9e1ba77f-f1e5-42f4-b090-437aa9af7f73', # Full name
          '68fbb180-9a2a-48f6-9da6-545e28b8d35a', # Do you like Star Wars?
          '09e91fd9-7a46-4840-adbc-244d545cfef7', # Branching point 1
          'e8708909-922e-4eaf-87a5-096f7a713fcb', # How well do you know Star Wars?
          '0b297048-aa4d-49b6-ac74-18e069118185', # What is your favourite fruit?
          'ffadeb22-063b-4e4f-9502-bd753c706b1d', # Branching point 2
          'd4342dfd-0d09-4a91-a0ea-d7fd67e706cc', # Do you like apple juice?
          '05c3306c-0a39-42d2-9e0f-93fd49248f4e', # What is your favourite band?
          '1d02e508-5953-4eca-af2f-9d67511c8648', # Branching point 3
          '8002df6e-29ab-4cdf-b520-1d7bb931a28f', # Which app do you use to listen music?
          'ef2cafe3-37e2-4533-9b0c-09a970cd38d4', # What is the best form builder?
          'cf8b3e18-dacf-4e91-92e1-018035961003', # Branching point 4
          'b5efc09c-ece7-45ae-b0b3-8a7905e25040', # Which Formbuilder is the best?
          '0c022e95-0748-4dda-8ba5-12fd1d2f596b', # What would you like on your burger?
          '618b7537-b42b-4551-ae7d-053afa4d9ca9', # Branching point 5
          'bc666714-c0a2-4674-afe5-faff2e20d847', # Global warming
          'dc7454f9-4186-48d7-b055-684d57bbcdc7', # What is the best marvel series?
          '84a347fc-8d4b-486a-9996-6a86fa9544c5', # Branching point 6
          '2cc66e51-2c14-4023-86bf-ded49887cdb2', # Loki
          '48357db5-7c06-4e85-94b1-5e1c9d8f39eb', # Select all Arnold Schwarzenegger quotes
          '1079b5b8-abd0-4bf6-aaac-1f01e69e3b39', # Branching point 7
          '56e80942-d0a4-405a-85cd-bd1b100013d6', # You are right
          'e337070b-f636-49a3-a65c-f506675265f0', # Check your answers
          '778e364b-9a7f-4829-8eb2-510e08f156a3'  # Complaint sent
        ]
      end

      it 'returns the flow uuids for all traversed flow objects for row zero' do
        expect(route.flow_uuids).to eq(expected_uuids)
      end

      it 'returns a route object for each possible conditional next' do
        expect(route.routes.size).to eq(potential_routes)
      end

      it 'adds the right column number to routes for objects in the same column' do
        wrong_gotg_uuid = '6324cca4-7770-4765-89b9-1cdc41f49c8b' # You are wrong - GOTG
        wrong_incomplete_uuid = '941137d7-a1da-43fd-994a-98a4f9ea6d46' # You are wrong - incomplete

        [wrong_gotg_uuid, wrong_incomplete_uuid].each do |uuid|
          column = route.routes.find { |r| r.traverse_from == uuid }.column
          expect(column).to eq(22)
        end
      end
    end

    context 'when traversing from later in the flow' do
      before do
        route.traverse
      end

      let(:traverse_from) { service.find_page_by_url('arnold-incomplete-answers').uuid }
      let(:column) { 22 }
      let(:expected_uuids) do
        [
          '941137d7-a1da-43fd-994a-98a4f9ea6d46', # You are wrong - incomplete
          'e337070b-f636-49a3-a65c-f506675265f0', # Check your answers
          '778e364b-9a7f-4829-8eb2-510e08f156a3'  # Complaint sent
        ]
      end

      it 'returns the flow uuids for all traversed flow objects' do
        expect(route.flow_uuids).to eq(expected_uuids)
      end

      it 'will have no additional routes since there are no more branching points' do
        expect(route.routes).to be_empty
      end
    end

    context 'when looping more times than the size of the service flow' do
      let(:column) { 10_000_000 }

      it 'raises a ExceededTotalFlowObjectsError' do
        expect(ActiveSupport::Notifications).to receive(:instrument).with(
          'exceeded_total_flow_objects',
          message: 'Exceeded total number of flow objects'
        )
        route.traverse
      end
    end
  end
end
