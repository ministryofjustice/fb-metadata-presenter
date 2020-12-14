RSpec.describe MetadataPresenter::BaseValidator do
  subject(:validator) do
    described_class.new(page: page, answers: answers, component: component)
  end
  let(:page) { service.find_page('/name') }
  let(:answers) { {} }
  let(:component) { page.components.first }

  describe '#default_error_message' do
    it 'raises no default message error' do
      expect { validator.default_error_message }.to raise_error(MetadataPresenter::NoDefaultMessage)
    end
  end

  describe '#invalid_answer?' do
    it 'raises not implemented error' do
      expect { validator.invalid_answer? }.to raise_error(NotImplementedError)
    end
  end
end
