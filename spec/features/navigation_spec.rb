RSpec.feature 'Navigation' do
  let(:form) { ComplainAboutTribunal.new }

  scenario 'fill a form and coming back' do
    given_the_service_has_a_metadata
    when_I_visit_the_service
    and_I_add_my_full_name
    and_I_add_my_email
    and_I_go_back_to_full_name_page
    then_I_should_see_my_full_name
  end

  def given_the_service_has_a_metadata
    expect(Rails.configuration).to receive(:service_metadata)
      .and_return(complain_about_tribunal_metadata)
      .at_least(:once)
  end

  def when_I_visit_the_service
    form.load
    form.start_button.click
  end

  def and_I_add_my_full_name
    form.full_name_field.set('Han Solo')
    form.continue_button.click
  end

  def and_I_add_my_email
    form.email_field.set('han.solo@gmail.com')
    form.continue_button.click
  end

  def and_I_go_back_to_full_name_page
    # Change this to click the back link when
    # we have the back link
    visit('/name')
  end

  def then_I_should_see_my_full_name
    expect(form.full_name_field.value).to eq('Han Solo')
  end

  def complain_about_tribunal_metadata
    JSON.parse(
      File.read(
        Rails.root.join('spec', 'fixtures', 'complain_about_tribunal.json')
      )
    )
  end
end
