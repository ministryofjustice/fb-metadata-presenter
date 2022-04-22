RSpec.describe MetadataPresenter::Grid do
  subject(:grid) { described_class.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching_5) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }

  describe '#build' do
    context 'when there is no starting uuid' do
      it 'should start at the start page' do
        expect(grid.build[0][0].uuid).to eq(service.start_page.uuid)
      end
    end

    context 'when there is a starting uuid' do
      subject(:grid) { described_class.new(service, start_from: page_d) }
      let(:page_d) { '65a2e01a-57dc-4702-8e41-ed8f9921ac7d' }

      it 'should start at the supplied uuid' do
        expect(grid.build[0][0].uuid).to eq(page_d)
      end
    end

    context 'when building the grid' do
      it 'does not allow duplicate objects' do
        # ignoring the Spacer objects
        flattened_grid = grid.build.flatten.reject { |f| f.is_a?(MetadataPresenter::Spacer) }
        expect(flattened_grid.count).to eq(service.flow.count)
      end

      context 'inserting spacers' do
        context 'branching fixture' do
          let(:latest_metadata) { metadata_fixture(:branching) }
          let(:expected_column_19) do
            [
              service.flow_object('2cc66e51-2c14-4023-86bf-ded49887cdb2'), # Loki
              MetadataPresenter::Spacer.new,
              service.flow_object('f6c51f88-7be8-4cb7-bbfc-6c905727a051') # Other Quotes
            ]
          end
          let(:expected_column_22) do
            [
              service.flow_object('56e80942-d0a4-405a-85cd-bd1b100013d6'), # You are right
              service.flow_object('6324cca4-7770-4765-89b9-1cdc41f49c8b'), # You are wrong
              MetadataPresenter::Spacer.new,
              service.flow_object('941137d7-a1da-43fd-994a-98a4f9ea6d46') # You are wrong (incomplete answers)
            ]
          end

          it 'inserts spacers in the correct rows' do
            flow_grid = grid.build
            expect(flow_grid[19]).to eq(expected_column_19)
            expect(flow_grid[22]).to eq(expected_column_22)
          end
        end

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
              service.flow_object('13ecf9bd-5064-4cad-baf8-3dfa091928cb'), # Page F
              service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d')  # Branching point 2
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
          let(:expected_column_6) do
            [
              service.flow_object('13ecf9bd-5064-4cad-baf8-3dfa091928cb'), # Page F
              service.flow_object('ffadeb22-063b-4e4f-9502-bd753c706b1d')  # Branching Point 2
            ]
          end
          let(:expected_column_7) do
            [
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('be130ac1-f33d-4845-807d-89b23b90d205'), # Page K
              service.flow_object('3a584d15-6805-4a21-bc05-b61c3be47857') # Page G
            ]
          end
          let(:expected_column_8) do
            [
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('2c7deb33-19eb-4569-86d6-462e3d828d87') # Page L
            ]
          end
          let(:expected_column_9) do
            [
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('d80a2225-63c3-4944-873f-504b61311a15') # Page M
            ]
          end

          it 'inserts enough spacers above in order to maintain row consistency' do
            flow_grid = grid.build
            expect(flow_grid[6]).to eq(expected_column_6)
            expect(flow_grid[7]).to eq(expected_column_7)
            expect(flow_grid[8]).to eq(expected_column_8)
            expect(flow_grid[9]).to eq(expected_column_9)
          end
        end

        context 'branching fixture 9' do
          let(:latest_metadata) { metadata_fixture(:branching_9) }
          let(:expected_column_9) do
            [
              service.flow_object('ced77b4d-efb5-4d07-b38b-2be9e09a73df'), # Page G
              service.flow_object('46693db1-8995-4af0-a2d1-316140a5fb32'), # Page L
              service.flow_object('c01ae632-1533-4ee3-8828-a0c547200129') # Page M
            ]
          end

          it 'puts the pages in the correct columns with spacers' do
            flow_grid = grid.build
            expect(flow_grid[9]).to eq(expected_column_9)
          end
        end

        context 'branching fixture 10 - visually stacking branch objects' do
          let(:latest_metadata) { metadata_fixture(:branching_10) }
          let(:expected_column_4) do
            [
              service.flow_object('66c9e581-942e-4a9e-93ec-343208a2f510'), # Page C
              service.flow_object('0dc31709-24de-4b2d-bd9d-490e9fec0366'), # Page I
              service.flow_object('ad011e6b-5926-42f8-8b7c-668558850c52')  # Page N
            ]
          end
          let(:expected_column_6) do
            [
              service.flow_object('19e4204d-672b-467e-9b8d-3a5cf22d9765'), # Branching Point 5
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('a02f7073-ba5a-459d-b6b9-abe548c933a6'), # Branching Point 2
              MetadataPresenter::Spacer.new,
              service.flow_object('4cad5db1-bf68-4f7f-baf6-b2d48b342705') # Branching Point3
            ]
          end
          let(:expected_column_9) do
            [
              service.flow_object('7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1'), # Branching Point 4
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('64c0a3ef-53cb-47f4-b771-0c4b65496030') # Page R
            ]
          end
          let(:expected_column_10) do
            [
              service.flow_object('ced77b4d-efb5-4d07-b38b-2be9e09a73df'), # Page G
              service.flow_object('46693db1-8995-4af0-a2d1-316140a5fb32'), # Page L
              service.flow_object('c01ae632-1533-4ee3-8828-a0c547200129'), # Page M
              MetadataPresenter::Spacer.new,
              MetadataPresenter::Spacer.new,
              service.flow_object('e047c5c8-457e-4f10-a4d8-1d927cd6b669') # Page S
            ]
          end
          let(:expected_column_16) do
            [service.flow_object('da2576f9-7ddd-4316-b24b-103708139214')] # Checkanswers
          end

          it 'inserts spacers in between branch objects in the same column as each other' do
            flow_grid = grid.build
            expect(flow_grid[4]).to eq(expected_column_4)
            expect(flow_grid[6]).to eq(expected_column_6)
            expect(flow_grid[9]).to eq(expected_column_9)
            expect(flow_grid[10]).to eq(expected_column_10)
            expect(flow_grid[16]).to eq(expected_column_16)
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

      context 'inserting pointers' do
        let(:main_flow) { grid.flow_uuids }
        let(:detached_grid) do
          described_class.new(service, start_from: start_from, main_flow: main_flow)
        end
        let(:cya_pointer) do
          MetadataPresenter::Pointer.new(uuid: 'e337070b-f636-49a3-a65c-f506675265f0')
        end

        context 'branching fixture 8' do
          let(:start_from) { 'be130ac1-f33d-4845-807d-89b23b90d205' } # Page K
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_8)
            flow = metadata['flow']['ffadeb22-063b-4e4f-9502-bd753c706b1d']
            # remove conditional pointing to Page K
            flow['next']['conditionals'] = [flow['next']['conditionals'].shift]
            metadata['flow']['ffadeb22-063b-4e4f-9502-bd753c706b1d'] = flow
            metadata
          end
          let(:expected_detached_flow) do
            [
              [service.flow_object(start_from)], # Page K
              [cya_pointer]
            ]
          end

          it 'places Pointer objects if UUID already exists in the main flow' do
            expect(detached_grid.build).to eq(expected_detached_flow)
          end
        end

        context 'branching fixture 6 - detaching a branching point' do
          let(:start_from) { '09e91fd9-7a46-4840-adbc-244d545cfef7' } # Branching Point 1
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_6)
            # point Page D to check answers page
            metadata['flow']['65a2e01a-57dc-4702-8e41-ed8f9921ac7d']['next']['default'] = 'e337070b-f636-49a3-a65c-f506675265f0'
            metadata
          end
          let(:expected_detached_flow) do
            [
              [
                service.flow_object(start_from) # Branching point 1
              ],
              [
                service.flow_object('37a94466-97fa-427f-88b2-09b369435d0d'), # Page E
                service.flow_object('520fde26-8124-4c67-a550-cd38d2ef304d') # Page I
              ],
              [
                MetadataPresenter::Spacer.new,
                service.flow_object('f475d6fd-0ea4-45d5-985e-e1a7c7a5b992') # Page J
              ],
              [
                MetadataPresenter::Spacer.new,
                service.flow_object('be130ac1-f33d-4845-807d-89b23b90d205') # Page K
              ],
              [
                MetadataPresenter::Spacer.new,
                service.flow_object('2c7deb33-19eb-4569-86d6-462e3d828d87') # Page L
              ],
              [
                cya_pointer
              ]
            ]
          end

          it 'inserts pointers as well as maintaining spacer object positions' do
            expect(detached_grid.build).to eq(expected_detached_flow)
          end
        end

        context 'branching fixture 11 - detached grids' do
          context 'removing excess pointers from detached grids' do
            let(:main_flow) { grid.flow_uuids }
            let(:start_from) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # branching point 2
            let(:latest_metadata) do
              metadata = metadata_fixture(:branching_11)
              # point page j to checkanswers, detaches branching point 2
              metadata['flow']['4e54ed97-d0df-462e-9a88-fd0f23ea62f5']['next']['default'] = 'da2576f9-7ddd-4316-b24b-103708139214'
              metadata
            end
            let(:detached_grid) do
              MetadataPresenter::Grid.new(service, start_from: start_from, main_flow: main_flow)
            end
            let(:expected_grid) do
              [
                [
                  service.flow_object(start_from) # Branching point 2
                ],
                [
                  service.flow_object('1314e473-9096-4434-8526-03a7b4b7b132'), # page k
                  MetadataPresenter::Pointer.new(uuid: 'da2576f9-7ddd-4316-b24b-103708139214'), # checkanswers
                  MetadataPresenter::Pointer.new(uuid: '7742dfcc-db2e-480b-9071-294fbe1769a2') # page f
                ],
                [
                  MetadataPresenter::Pointer.new(uuid: '007f4f35-8236-40cc-866c-cc2c27c33949') # page e
                ]
              ]
            end

            it 'shows last pointer for row and removes rows with only pointers unless branch destination' do
              expect(detached_grid.build).to eq(expected_grid)
            end
          end

          context 'with several pages pointing to the same Pointer object' do
            let(:main_flow) { grid.flow_uuids }
            let(:start_from) { '7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1' } # branching point 4
            let(:latest_metadata) do
              metadata = metadata_fixture(:branching_11)
              # point branching point 4 otherwise to check answers
              metadata['flow']['7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1']['next']['default'] = 'da2576f9-7ddd-4316-b24b-103708139214'
              # point page f to checkanswers, detaches branching point 4
              metadata['flow']['7742dfcc-db2e-480b-9071-294fbe1769a2']['next']['default'] = 'da2576f9-7ddd-4316-b24b-103708139214'
              metadata
            end
            let(:detached_grid) do
              MetadataPresenter::Grid.new(service, start_from: start_from, main_flow: main_flow)
            end
            let(:expected_grid) do
              [
                [
                  service.flow_object(start_from) # Branching point 4
                ],
                [
                  service.flow_object('ced77b4d-efb5-4d07-b38b-2be9e09a73df'), # page g
                  service.flow_object('46693db1-8995-4af0-a2d1-316140a5fb32'), # page l
                  service.flow_object('c01ae632-1533-4ee3-8828-a0c547200129'), # page m
                  service.flow_object('ad011e6b-5926-42f8-8b7c-668558850c52') # page n
                ],
                [
                  service.flow_object('81510f97-b4c0-43f1-bdde-1cd5159093a9'), # page h
                  MetadataPresenter::Spacer.new,
                  MetadataPresenter::Spacer.new,
                  service.flow_object('957f9475-6341-418d-a554-d00c5700e031') # page o
                ],
                [
                  MetadataPresenter::Spacer.new,
                  MetadataPresenter::Spacer.new,
                  MetadataPresenter::Spacer.new,
                  service.flow_object('4cad5db1-bf68-4f7f-baf6-b2d48b342705') # branching point 3
                ],
                [
                  MetadataPresenter::Spacer.new,
                  MetadataPresenter::Spacer.new,
                  MetadataPresenter::Spacer.new,
                  service.flow_object('79c18654-7ecb-43f9-bd7f-0b09eb9c075e') # page p
                ],
                [
                  MetadataPresenter::Pointer.new(uuid: 'da2576f9-7ddd-4316-b24b-103708139214') # checkanswers
                ]
              ]
            end

            it 'should only show one Pointer' do
              expect(detached_grid.build).to eq(expected_grid)
            end
          end
        end
      end

      context 'branching fixture 11 - pages linking backwards in the flow' do
        let(:latest_metadata) { metadata_fixture(:branching_11) }

        context 'main flow' do
          let(:expected_grid) do
            [
              [service.flow_object('c73dcd99-ade5-4bc9-b5b6-56325fcb5a02')], # Start
              [service.flow_object('1d60bef0-100a-4f3b-9e6f-1711e8adda7e')], # Page A
              [service.flow_object('2ffc17b7-b14a-417f-baff-07adebd4f259')], # Page B
              [service.flow_object('f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c')], # Branching Point 1
              [
                service.flow_object('66c9e581-942e-4a9e-93ec-343208a2f510'), # Page C
                service.flow_object('0dc31709-24de-4b2d-bd9d-490e9fec0366')  # Page I
              ],
              [
                service.flow_object('e31718ad-0ba7-4b45-81aa-d3081f423022'), # Page D
                service.flow_object('4e54ed97-d0df-462e-9a88-fd0f23ea62f5')  # Page J
              ],
              [
                service.flow_object('007f4f35-8236-40cc-866c-cc2c27c33949'), # Page E
                service.flow_object('a02f7073-ba5a-459d-b6b9-abe548c933a6')  # Branching Point 2
              ],
              [
                service.flow_object('7742dfcc-db2e-480b-9071-294fbe1769a2'), # Page F
                service.flow_object('1314e473-9096-4434-8526-03a7b4b7b132')  # Page K
              ],
              [service.flow_object('7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1')], # Branching Point 4
              [
                service.flow_object('ced77b4d-efb5-4d07-b38b-2be9e09a73df'), # Page G
                service.flow_object('46693db1-8995-4af0-a2d1-316140a5fb32'), # Page L
                service.flow_object('c01ae632-1533-4ee3-8828-a0c547200129'), # Page M
                service.flow_object('ad011e6b-5926-42f8-8b7c-668558850c52')  # Page N
              ],
              [
                service.flow_object('81510f97-b4c0-43f1-bdde-1cd5159093a9'), # Page H
                MetadataPresenter::Spacer.new,
                MetadataPresenter::Spacer.new,
                service.flow_object('957f9475-6341-418d-a554-d00c5700e031')  # Page O
              ],
              [
                MetadataPresenter::Spacer.new,
                MetadataPresenter::Spacer.new,
                MetadataPresenter::Spacer.new,
                service.flow_object('4cad5db1-bf68-4f7f-baf6-b2d48b342705')  # Branching Point 3
              ],
              [
                MetadataPresenter::Spacer.new,
                MetadataPresenter::Spacer.new,
                MetadataPresenter::Spacer.new,
                service.flow_object('79c18654-7ecb-43f9-bd7f-0b09eb9c075e')  # Page P
              ],
              [service.flow_object('da2576f9-7ddd-4316-b24b-103708139214')], # Checkanswers
              [service.flow_object('a88694da-8ded-44e7-bc89-e652c1a7f46d')]  # Confirmation
            ]
          end

          it 'builds the correct main flow' do
            expect(grid.build).to eq(expected_grid)
          end
        end

        context 'with detached objects' do
          subject(:grid) do
            described_class.new(
              service,
              start_from: 'b89d0b03-a709-4cd6-84dd-bc441118b4b8', # Page Q
              main_flow: main_flow
            )
          end
          let(:main_flow) { described_class.new(service).flow_uuids }
          let(:expected_grid) do
            [
              [service.flow_object('b89d0b03-a709-4cd6-84dd-bc441118b4b8')], # Page Q
              [service.flow_object('645e3bb4-523b-448f-8734-7d7726d27529')], # Page R
              [service.flow_object('a7fe1073-cc11-4aef-a533-d3060117534d')], # Page S
              [MetadataPresenter::Pointer.new(uuid: '957f9475-6341-418d-a554-d00c5700e031')] # Page O
            ]
          end

          it 'builds the correct detached flow ending in a pointer' do
            expect(grid.build).to eq(expected_grid)
          end
        end
      end

      context 'inserting warnings' do
        let(:warning) { [MetadataPresenter::Warning.new] }

        context 'when cya and confirmation do not exist' do
          let(:latest_metadata) { metadata_fixture(:exit_only_service) }

          it 'inserts warning at the end of the flow' do
            flow_grid = grid.build
            expect(flow_grid.last).to eq(warning)
          end
        end

        context 'when cya does not exist in the service' do
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_6)
            metadata['flow'].delete('e337070b-f636-49a3-a65c-f506675265f0') # delete CYA page
            metadata['flow']['37a94466-97fa-427f-88b2-09b369435d0d']['next']['default'] = '778e364b-9a7f-4829-8eb2-510e08f156a3' # Page E
            metadata['flow']['2c7deb33-19eb-4569-86d6-462e3d828d87']['next']['default'] = '778e364b-9a7f-4829-8eb2-510e08f156a3' # Page L
            metadata['pages'] = metadata['pages'].reject do |page|
              page['_uuid'] == 'e337070b-f636-49a3-a65c-f506675265f0'
            end
            metadata
          end

          it 'inserts warning at the end of the flow' do
            flow_grid = grid.build
            expect(flow_grid.last).to eq(warning)
          end
        end

        context 'when confirmation does not exist in the service' do
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_6)
            metadata['flow'].delete('778e364b-9a7f-4829-8eb2-510e08f156a3') # delete Confirmation page
            metadata['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # Change CYA default
            metadata['pages'] = metadata['pages'].reject do |page|
              page['_uuid'] == '778e364b-9a7f-4829-8eb2-510e08f156a3'
            end
            metadata
          end

          it 'inserts warning at the end of the flow' do
            flow_grid = grid.build
            expect(flow_grid.last).to eq(warning)
          end
        end

        context 'disconnected cya page' do
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_6)
            # Have Page E and Page L default to Confirmation
            metadata['flow']['37a94466-97fa-427f-88b2-09b369435d0d']['next']['default'] = '778e364b-9a7f-4829-8eb2-510e08f156a3' # Page E
            metadata['flow']['2c7deb33-19eb-4569-86d6-462e3d828d87']['next']['default'] = '778e364b-9a7f-4829-8eb2-510e08f156a3' # Page L
            metadata
          end

          it 'inserts warning at the end of the flow' do
            flow_grid = grid.build
            expect(flow_grid.last).to eq(warning)
          end
        end

        context 'disconnected confirmation page' do
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_6)
            metadata['flow']['e337070b-f636-49a3-a65c-f506675265f0']['next']['default'] = '' # Change CYA default
            metadata
          end

          it 'inserts warning at the end of the flow' do
            flow_grid = grid.build
            expect(flow_grid.last).to eq(warning)
          end
        end

        context 'disconnected cya and confirmation pages' do
          let(:latest_metadata) do
            metadata = metadata_fixture(:branching_6)
            # Have Page E and Page L defaults
            metadata['flow']['37a94466-97fa-427f-88b2-09b369435d0d']['next']['default'] = '' # Page E
            metadata['flow']['2c7deb33-19eb-4569-86d6-462e3d828d87']['next']['default'] = '' # Page L
            metadata
          end

          it 'inserts warning at the end of the flow' do
            flow_grid = grid.build
            expect(flow_grid.last).to eq(warning)
          end
        end
      end

      context 'inserting confirmation page' do
        let(:latest_metadata) { metadata_fixture(:branching_12) }
        let(:confirmation_uuid) { '48b0bcd1-7ab1-424f-8250-9a1f0beed2f7' }

        it 'builds the correct main flow' do
          # The confirmation page will always be in the last column, first row
          expect(grid.build.last.first.uuid).to eq(confirmation_uuid)
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

  describe '#flow_uuids' do
    context 'fixtures with no detached objects' do
      branching_fixtures = %i[
        branching
        branching_2
        branching_3
        branching_4
        branching_5
        branching_6
        branching_7
        branching_8
        branching_9
        branching_10
      ]

      branching_fixtures.each do |fixture|
        context "with #{fixture} fixture" do
          let(:latest_metadata) { metadata_fixture(fixture) }
          let(:expected_uuids) { service.flow.keys }

          it 'returns an array of all the flow uuids - nothing has been overwritten' do
            expect(grid.flow_uuids).to match_array(expected_uuids)
          end
        end
      end
    end

    context 'fixtures with detached objects' do
      context 'branching fixture 11' do
        let(:latest_metadata) { metadata_fixture(:branching_11) }
        let(:expected_detached_uuids) do
          [
            'b89d0b03-a709-4cd6-84dd-bc441118b4b8', # Page Q
            '645e3bb4-523b-448f-8734-7d7726d27529', # Page R
            'a7fe1073-cc11-4aef-a533-d3060117534d'  # Page S
          ]
        end

        it 'does not include the detached uuids' do
          difference = service.flow.keys - grid.flow_uuids
          expect(difference).to match_array(expected_detached_uuids)
        end
      end
    end
  end

  describe '#page_uuids' do
    let(:expected_uuids) { service.pages.map(&:uuid) }

    it 'returns an array of only page uuids' do
      expect(grid.page_uuids).to match_array(expected_uuids)
    end
  end

  context 'previous flow uuids and conditional uuids' do
    let(:latest_metadata) { metadata_fixture(:branching_10) }
    let(:previous_uuids) { grid.previous_uuids }
    let(:previous_uuid_details) { grid.previous_uuids[uuid] }

    before do
      grid.build
    end

    context 'first object in grid' do
      let(:uuid) { service.start_page.uuid }
      let(:expected_previous_uuid_details) do
        { previous_flow_uuid: nil, conditional_uuid: nil }
      end

      it 'does not set the previous uuid or conditional uuid' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    context 'page object in flow' do
      let(:uuid) { 'e31718ad-0ba7-4b45-81aa-d3081f423022' } # Page D
      let(:expected_previous_uuid_details) do
        {
          previous_flow_uuid: '66c9e581-942e-4a9e-93ec-343208a2f510', # Page C
          conditional_uuid: nil
        }
      end

      it 'sets the previous flow uuid and conditional uuid' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    context 'branch object in flow' do
      let(:uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2
      let(:expected_previous_uuid_details) do
        {
          previous_flow_uuid: '4e54ed97-d0df-462e-9a88-fd0f23ea62f5', # Page J
          conditional_uuid: nil
        }
      end

      it 'sets the previous flow uuid and conditional uuid' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    context 'branch destination in flow' do
      let(:uuid) { 'c01ae632-1533-4ee3-8828-a0c547200129' } # Page M
      let(:expected_previous_uuid_details) do
        {
          previous_flow_uuid: '7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1', # Branching Point 4
          conditional_uuid: '5057d39b-99e8-4252-9637-b88a2d8a8d01'
        }
      end

      it 'sets the previous flow uuid and conditional uuid' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    context 'page pointed to multiple times in flow' do
      let(:uuid) { 'da2576f9-7ddd-4316-b24b-103708139214' } # Check Answers
      let(:expected_previous_uuid_details) do
        {
          previous_flow_uuid: '81510f97-b4c0-43f1-bdde-1cd5159093a9', # Page H
          conditional_uuid: nil
        }
      end

      # flow objects are placed in a specific order; left to right and then
      # branch destinations in order of the conditionals saved on the branch
      # branching point. The checks answers page is pointed to multiple times
      # but it will only ever share the same row visually as Page H
      it 'uses the first previous uuid and conditional uuid that is set for the object' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    context 'when branch default next' do
      let(:uuid) { 'ad011e6b-5926-42f8-8b7c-668558850c52' } # Page N
      let(:expected_previous_uuid_details) do
        {
          previous_flow_uuid: 'f55d002d-b2c1-4dcc-87b7-0da7cbc5c87c', # Branching Point 1
          conditional_uuid: nil
        }
      end

      # Page N is pointed to by Branching Points 1 and 4. Branching Point 1 will
      # be traversed first so it will be used as the previous uuid
      it 'uses the first previous uuid and sets nil for conditional uuid' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    context 'when multiple branch destinations point to the same page' do
      let(:latest_metadata) { metadata_fixture(:branching) }
      let(:uuid) { '2cc66e51-2c14-4023-86bf-ded49887cdb2' } # Loki
      let(:expected_previous_uuid_details) do
        {
          previous_flow_uuid: '84a347fc-8d4b-486a-9996-6a86fa9544c5', # Branching Point 6
          conditional_uuid: '15e8076f-75ac-4310-89b3-d2b5962babd4' # First conditional uuid
        }
      end

      it 'uses the first conditional uuid it comes to' do
        expect(previous_uuid_details).to eq(expected_previous_uuid_details)
      end
    end

    describe '#previous_uuid_for_object' do
      let(:uuid) { '97533725-14d7-4838-9335-58ceaed9aa13' } # Page Q
      let(:expected_previous_flow_uuid) { '1314e473-9096-4434-8526-03a7b4b7b132' } # Page K

      before do
        grid.build
      end

      it 'returns the previous flow uuid for a given flow object' do
        expect(grid.previous_uuid_for_object(uuid)).to eq(expected_previous_flow_uuid)
      end

      it 'returns nil for uuid that does not exist in previous_uuids' do
        expect(grid.previous_uuid_for_object('foo')).to be_nil
      end
    end

    describe '#conditional_uuid_for_object' do
      let(:uuid) { '46693db1-8995-4af0-a2d1-316140a5fb32' } # Page L
      let(:expected_conditional_uuid) { 'ba60fb61-9258-461e-964c-a9dfe9722f46' } # Conditional destination of Branching Point 4

      before do
        grid.build
      end

      it 'returns the conditional uuid for a given flow object' do
        expect(grid.conditional_uuid_for_object(uuid)).to eq(expected_conditional_uuid)
      end

      it 'returns nil for uuid that does not exist in previous_uuids' do
        expect(grid.conditional_uuid_for_object('bar')).to be_nil
      end
    end
  end
end
