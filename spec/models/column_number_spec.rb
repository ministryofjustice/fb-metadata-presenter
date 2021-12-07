RSpec.describe MetadataPresenter::ColumnNumber do
  subject(:column_number) { described_class.new(attributes) }
  let(:attributes) do
    {
      uuid: uuid,
      coordinates: coordinates,
      new_column: new_column
    }
  end
  let(:uuid) { SecureRandom.uuid }
  let(:coordinates) { MetadataPresenter::Coordinates.new(double) }

  describe '#number' do
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)
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

        it 'returns the new column number' do
          expect(column_number.number).to eq(new_column)
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
    end
  end
end
