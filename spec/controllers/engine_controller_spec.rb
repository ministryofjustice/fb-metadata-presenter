RSpec.describe MetadataPresenter::EngineController, type: :controller do
  describe '#back_link' do
    before do
      allow(controller.request).to receive(:script_name).and_return(script_name)
      allow(controller.request).to receive(:referrer).and_return(referrer)
      RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
      allow(controller.response).to receive(:status).and_return(status)
      controller.instance_variable_set(:@page, page)
    end

    after do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
    end

    context 'when in preview' do
      let(:script_name) do
        '/services/1/preview'
      end

      context 'when there is a page' do
        let(:status) { 200 }
        let(:page) { MetadataPresenter::Page.new(service.pages.second) }
        let(:referrer) { 'http://localhost:3000/services/1/preview' }

        it 'returns the previous page' do
          expect(controller.back_link).to eq('/services/1/preview/')
        end
      end

      context 'when there is no page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.first) }
        let(:referrer) { nil }
        let(:status) { 404 }

        it 'returns nil' do
          expect(controller.back_link).to be_nil
        end
      end
    end

    context 'when in the runner' do
      let(:script_name) { '' }

      context 'when there is a page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.second) }
        let(:referrer) { '/' }
        let(:status) { 200 }


        it 'returns the previous page' do
          expect(controller.back_link).to eq('/')
        end
      end

      context 'when there is no page' do
        let(:referrer) { nil }
        let(:status) { 404 }
        let(:page) { MetadataPresenter::Page.new(service.pages.second) }

        it 'returns nil' do
          expect(controller.back_link).to be_nil
        end
      end
    end
  end

  describe '#analytics_cookie_name' do
    it 'returns the correct analytics cookie name' do
      expect(controller.analytics_cookie_name).to eq('analytics-version-fixture')
    end
  end

  describe '#show_cookie_request?' do
    context 'when analytics cookie is present' do
      let(:cookies) do
        ActionDispatch::Cookies::CookieJar.build(request, { 'analytics-version-fixture' => 'accepted' })
      end

      before do
        allow_any_instance_of(MetadataPresenter::EngineController).to receive(:cookies).and_return(cookies)
      end

      context 'when analytics tags are present' do
        before do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with('UA').and_return('some-analytics-tag')
        end

        it 'returns falsey' do
          expect(controller.show_cookie_request?).to be_falsey
        end
      end

      context 'when analytics tag is not present' do
        it 'returns falsey' do
          expect(controller.show_cookie_request?).to be_falsey
        end
      end
    end

    context 'when analytics cookie is not present' do
      context 'when at least one analytics tag is present' do
        before do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with('GA4').and_return('some-analytics-tag')
        end

        it 'returns truthy' do
          expect(controller.show_cookie_request?).to be_truthy
        end
      end
    end
  end

  describe '#show_cookie_confirmation?' do
    context 'when analytics param is present' do
      before do
        controller.params[:analytics] = 'accepted'
      end

      context 'when analytics cookie is present' do
        let(:cookies) do
          ActionDispatch::Cookies::CookieJar.build(request, { 'analytics-version-fixture' => 'accepted' })
        end

        before do
          allow_any_instance_of(MetadataPresenter::EngineController).to receive(:cookies).and_return(cookies)
        end

        context 'when analytics tags are present' do
          before do
            allow(ENV).to receive(:[])
            allow(ENV).to receive(:[]).with('UA').and_return('some-analytics-tag')
          end

          it 'returns truthy' do
            expect(controller.show_cookie_confirmation?).to be_truthy
          end
        end

        context 'when analytics tag is not present' do
          it 'returns falsey' do
            expect(controller.show_cookie_confirmation?).to be_falsey
          end
        end
      end

      context 'when analytics cookie is not present' do
        context 'when at least one analytics tag is present' do
          before do
            allow(ENV).to receive(:[])
            allow(ENV).to receive(:[]).with('GA4').and_return('some-analytics-tag')
          end

          it 'returns falsey' do
            expect(controller.show_cookie_confirmation?).to be_falsey
          end
        end
      end
    end

    context 'when analytics param is not present' do
      context 'when analytics cookie is present' do
        let(:cookies) do
          ActionDispatch::Cookies::CookieJar.build(request, { 'analytics-version-fixture' => 'accepted' })
        end

        before do
          allow_any_instance_of(MetadataPresenter::EngineController).to receive(:cookies).and_return(cookies)
        end

        context 'when analytics tags are present' do
          before do
            allow(ENV).to receive(:[])
            allow(ENV).to receive(:[]).with('UA').and_return('some-analytics-tag')
          end

          it 'returns falsey' do
            expect(controller.show_cookie_confirmation?).to be_falsey
          end
        end

        context 'when analytics tag is not present' do
          it 'returns falsey' do
            expect(controller.show_cookie_confirmation?).to be_falsey
          end
        end
      end

      context 'when analytics cookie is not present' do
        context 'when at least one analytics tag is present' do
          before do
            allow(ENV).to receive(:[])
            allow(ENV).to receive(:[]).with('GA4').and_return('some-analytics-tag')
          end

          it 'returns falsey' do
            expect(controller.show_cookie_confirmation?).to be_falsey
          end
        end
      end
    end
  end

  describe '#allow_analytics?' do
    context 'when analytics cookie is present' do
      let(:cookies) do
        ActionDispatch::Cookies::CookieJar.build(request, { 'analytics-version-fixture' => 'accepted' })
      end

      before do
        allow_any_instance_of(MetadataPresenter::EngineController).to receive(:cookies).and_return(cookies)
      end

      it 'returns truthy' do
        expect(controller.allow_analytics?).to be_truthy
      end
    end

    context 'when no analytics cookie is present' do
      it 'returns falsey' do
        expect(controller.allow_analytics?).to be_falsey
      end
    end

    context 'when analytics cookie is set to rejected' do
      let(:cookies) do
        ActionDispatch::Cookies::CookieJar.build(request, { 'analytics-version-fixture' => 'rejected' })
      end

      before do
        allow_any_instance_of(MetadataPresenter::EngineController).to receive(:cookies).and_return(cookies)
      end

      it 'returns falsey' do
        expect(controller.allow_analytics?).to be_falsey
      end
    end
  end

  context 'maintenance mode' do
    context 'when maintenance mode is enabled' do
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('MAINTENANCE_MODE').and_return('1')
      end

      before :each do
        subject { get '/' }
      end

      describe '#maintenance_mode' do
        it 'returns true' do
          expect(controller.maintenance_mode?).to be_truthy
        end
      end
    end

    context 'when maintenance mode is not enabled' do
      describe '#maintenance_mode' do
        it 'returns true' do
          expect(controller.maintenance_mode?).to be_falsey
        end
      end
    end
  end

  describe '#external_or_relative_link' do
    context 'when link is fully qualified' do
      let(:link) { 'https://www.example.com' }

      it 'returns the fully qualified link' do
        expect(controller.external_or_relative_link(link)).to eq(link)
      end
    end

    context 'when link does not have / at start' do
      let(:link) { 'somelink' }

      it 'prepends / at the beginning of the relative link' do
        expect(controller.external_or_relative_link(link)).to eq('/somelink')
      end
    end

    context 'when link does have / at the start' do
      let(:link) { '/somelink' }

      it 'returns the relative link' do
        expect(controller.external_or_relative_link(link)).to eq(link)
      end
    end

    context 'when in preview in the editor' do
      let(:link) { '/somelink' }
      let(:original_url) { "http://some-domain.com#{preview_path}" }
      let(:preview_path) { '/services/some-service-id/preview' }

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:original_url).and_return(original_url)
        allow_any_instance_of(ActionDispatch::Request).to receive(:script_name).and_return(preview_path)
      end

      it 'uses the request script name to build the correct path' do
        expect(controller.external_or_relative_link(link)).to eq('/services/some-service-id/preview/somelink')
      end
    end
  end

  describe '#answered?' do
    let(:page) { MetadataPresenter::Page.new(service.pages.first) }
    let(:component_id) { 'text_text_1' }
    let(:page_answers) { MetadataPresenter::PageAnswers.new(page, answers) }

    before do
      controller.instance_variable_set(:@page_answers, page_answers)
    end

    context 'when component has an answer' do
      let(:answers) { { component_id => 'pouf' } }

      it 'returns true' do
        expect(controller.answered?(component_id)).to be_truthy
      end
    end

    context 'when component has no answer' do
      let(:answers) { { component_id => '' } }

      it 'returns false' do
        expect(controller.answered?(component_id)).to be_falsey
      end
    end
  end

  describe '#load_autocomplete_items' do
    let(:page) { MetadataPresenter::Page.new(service.pages.first) }
    let(:items) { { 'component_id' => [{ 'text' => 'abc', 'value' => '123' }] } }
    let(:autocomplete_items) { items }

    context 'when there is an autocomplete component on the page' do
      before do
        allow(page).to receive(:autocomplete_component_present?).and_return(true)
        allow(page).to receive(:assign_autocomplete_items)
        controller.instance_variable_set(:@page, page)
      end

      it 'load the autocomplete items' do
        expect(controller).to receive(:autocomplete_items)
        controller.load_autocomplete_items
      end
    end
  end
end
