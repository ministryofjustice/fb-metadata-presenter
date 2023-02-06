RSpec.describe MetadataPresenter::ColumnNumber do
  subject(:column_number) { described_class.new(attributes) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:attributes) do
    {
      uuid:,
      coordinates:,
      new_column:,
      service:
    }
  end
  let(:uuid) { SecureRandom.uuid }
  let(:coordinates) { MetadataPresenter::Coordinates.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching_10) }
  let(:positions) { {} }

  describe '#number' do
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(
        service.flow.keys.index_with { |_uuid| { row: nil, column: nil } }.merge(positions)
      )
    end

    context 'when no column has been set before' do
      let(:positions) do
        {
          uuid => {
            column: nil,
            row: nil
          }
        }
      end
      let(:new_column) { 1 }

      it 'returns the new column number' do
        expect(column_number.number).to eq(new_column)
      end
    end

    context 'when column number exists' do
      context 'when the new column is greater than the existing column' do
        let(:positions) do
          {
            uuid => {
              column: 1,
              row: 1
            }
          }
        end
        let(:new_column) { 10 }

        it 'returns the existing column number' do
          expect(column_number.number).to eq(1)
        end
      end

      context 'when the new column is not greater than the existing column' do
        let(:positions) do
          {
            uuid => {
              column: 10,
              row: 1
            }
          }
        end
        let(:new_column) { 1 }

        it 'returns the existing column number' do
          expect(column_number.number).to eq(10)
        end
      end

      context 'when checkanswers page' do
        # branching fixture 10 CYA page
        let(:uuid) { 'da2576f9-7ddd-4316-b24b-103708139214' }
        let(:positions) do
          {
            uuid => {
              column: 8,
              row: 1
            }
          }
        end

        context 'when existing column is less than new column' do
          let(:new_column) { 10 }

          it 'returns the new column' do
            expect(column_number.number).to eq(new_column)
          end
        end

        context 'when existing column is more than new column' do
          let(:new_column) { 6 }

          it 'returns the existing column' do
            expect(column_number.number).to eq(8)
          end
        end

        context 'when existing column is not present' do
          let(:positions) do
            {
              uuid => {
                column: nil,
                row: 1
              }
            }
          end
          let(:new_column) { 8 }

          it 'returns the new column' do
            expect(column_number.number).to eq(8)
          end
        end
      end

      context 'when confirmation page' do
        # branching fixture 10 Confirmation page
        let(:uuid) { 'a88694da-8ded-44e7-bc89-e652c1a7f46d' }
        context 'when checkanswers page is present' do
          let(:positions) do
            {
              # branching fixture 10 CYA page
              'da2576f9-7ddd-4316-b24b-103708139214' => {
                column: 10,
                row: 1
              }
            }
          end
          let(:new_column) { 10 }

          it 'returns the last column' do
            expect(column_number.number).to eq(11)
          end
        end

        context 'when checkanswers page is not present' do
          let(:positions) do
            {
              # branching fixture 10 Confirmation page
              uuid => {
                column: 8,
                row: 1
              }
            }
          end

          context 'when existing column is less than new column' do
            let(:new_column) { 10 }

            it 'returns the new column' do
              expect(column_number.number).to eq(new_column)
            end
          end

          context 'when existing column is more than new column' do
            let(:new_column) { 7 }

            it 'returns the existing column' do
              expect(column_number.number).to eq(8)
            end
          end

          context 'when there is no existing column' do
            let(:positions) do
              {
                # branching fixture 10 Confirmation page
                uuid => {
                  column: nil,
                  row: 1
                }
              }
            end
            let(:new_column) { 6 }

            it 'returns the new column' do
              expect(column_number.number).to eq(new_column)
            end
          end
        end
      end

      context 'when object is a branch' do
        let(:new_column) { 1 }
        let(:uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2

        it 'sets the column number for each branch spacer in the coordinates' do
          expect(coordinates).to receive(:set_branch_spacers_column).with(uuid, new_column).once
          column_number.number
        end
      end
    end
  end
end
