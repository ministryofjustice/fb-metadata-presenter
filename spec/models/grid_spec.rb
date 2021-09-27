RSpec.describe MetadataPresenter::Grid do
  subject(:grid) { described_class.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching_5) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }

  describe '#build' do
    context 'when building the grid' do
      it 'does not allow duplicate objects' do
        # ignoring the Spacer objects
        flattened_grid = grid.build.flatten.reject { |f| f.is_a?(MetadataPresenter::Spacer) }
        expect(flattened_grid.count).to eq(service.flow.count)
      end

      context 'inserting spacers' do
        context 'branching fixture 5' do
          let(:expected_column_4) do
            [
              service.flow_object('65a2e01a-57dc-4702-8e41-ed8f9921ac7d'), # Page D
              MetadataPresenter::Spacer.new,
              service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d') # Branching Point 2
            ]
          end

          let(:expected_column_5) do
            [
              service.flow_object('37a94466-97fa-427f-88b2-09b369435d0d'), # Page E
              MetadataPresenter::Spacer.new,
              service.flow_object('be130ac1-f33d-4845-807d-89b23b90d205'), # Page K
              service.flow_object('d80a2225-63c3-4944-873f-504b61311a15')  # Page M
            ]
          end
          let(:expected_column_6) do
            [
              service.flow_object('13ecf9bd-5064-4cad-baf8-3dfa091928cb'), # Page F
              MetadataPresenter::Spacer.new,
              service.flow_object('2c7deb33-19eb-4569-86d6-462e3d828d87'), # Page L
              service.flow_object('393645a4-f037-4e75-8359-51f9b0e360fb')  # Page N
            ]
          end

          it 'inserts spacers in the correct rows' do
            flow_grid = grid.build
            expect(flow_grid[4]).to eq(expected_column_4)
            expect(flow_grid[5]).to eq(expected_column_5)
            expect(flow_grid[6]).to eq(expected_column_6)
          end
        end

        context 'branching fixture 7' do
          let(:latest_metadata) { metadata_fixture(:branching_7) }
          let(:expected_column_6) do
            [
              MetadataPresenter::Spacer.new,
              service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d') # Branching point 2
            ]
          end

          it 'inserts a spacer above a branch when a destination is pointed to by a previous object on the row above' do
            expect(grid.build[6]).to eq(expected_column_6)
          end
        end

        context 'branching fixture 2' do
          let(:latest_metadata) { metadata_fixture(:branching_2) }

          it 'does not insert a spacer above a branch if no objects on rows above point to any of the branch destinations' do
            expect(grid.build[4].any? { |obj| obj.is_a?(MetadataPresenter::Spacer) }).to be_falsey
          end
        end

        context 'branching fixture 8' do
          let(:latest_metadata) { metadata_fixture(:branching_8) }
          let(:expected_column_8) do
            [
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('2c7deb33-19eb-4569-86d6-462e3d828d87') # Page L
            ]
          end
          let(:expected_column_9) do
            [
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('d80a2225-63c3-4944-873f-504b61311a15') # Page M
            ]
          end

          it 'does something' do
            flow_grid = grid.build
            expect(flow_grid[8]).to eq(expected_column_8)
            expect(flow_grid[9]).to eq(expected_column_9)
          end
        end

        context 'when looping exceeds the total potential routes' do
          it 'raises a ExceededPotentialRoutesError' do
            allow(grid).to receive(:total_potential_routes).and_return(1)
            expect(ActiveSupport::Notifications).to receive(:instrument).with(
              'exceeded_total_potential_routes',
              message: 'Exceeded total number of potential routes'
            )
            grid.build
          end
        end
      end
    end
  end

  describe '#ordered_pages' do
    context 'when excluding branches' do
      it 'does not include any branch flow objects' do
        expect(grid.ordered_pages.any? { |flow| flow.type == 'flow.branch' }).to be_falsey
      end

      it 'only returns MetadataPresenter::Flow objects' do
        grid.ordered_flow.each do |obj|
          expect(obj).to be_a_kind_of(MetadataPresenter::Flow)
        end
      end
    end

    context 'when building the pages' do
      before do
        grid.ordered_pages
      end

      it 'only builds the grid once' do
        expect(grid).not_to receive(:build)
        grid.ordered_pages
        grid.ordered_pages
      end
    end
  end

  describe '#ordered_flow' do
    context 'when including branches' do
      it 'includes flow branch objects' do
        expect(grid.ordered_flow.any? { |flow| flow.type == 'flow.branch' }).to be_truthy
      end

      it 'only returns MetadataPresenter::Flow objects' do
        grid.ordered_flow.each do |obj|
          expect(obj).to be_a_kind_of(MetadataPresenter::Flow)
        end
      end
    end

    context 'when building the ordered flow' do
      before do
        grid.ordered_flow
      end

      it 'only builds the grid once' do
        expect(grid).not_to receive(:build)
        grid.ordered_flow
        grid.ordered_flow
      end
    end
  end
end
