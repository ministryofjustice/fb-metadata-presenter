RSpec.describe MetadataPresenter::EngineController, type: :controller do
  describe '#back_link' do
    before do
      allow(controller.request).to receive(:script_name).and_return(script_name)
      allow(controller.request).to receive(:referrer).and_return(referrer)
    end

    context 'when in preview' do
      let(:script_name) do
        '/services/1/preview'
      end

      before do
        controller.instance_variable_set(:@page, page)
      end

      context 'when there is a page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.second) }
        let(:referrer) { 'http://localhost:3000/services/1/preview' }

        it 'returns the previous page' do
          expect(controller.back_link).to eq('/services/1/preview/')
        end
      end

      context 'when there is no page' do
        let(:page) { MetadataPresenter::Page.new(service.pages.first) }
        let(:referrer) { nil }

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

        before do
          controller.instance_variable_set(:@page, page)
        end

        it 'returns the previous page' do
          expect(controller.back_link).to eq('/')
        end
      end

      context 'when there is no page' do
        let(:referrer) { nil }

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

  describe '#show_cookie_banner?' do
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
          expect(controller.show_cookie_banner?).to be_falsey
        end
      end

      context 'when analytics tag is not present' do
        it 'returns falsey' do
          expect(controller.show_cookie_banner?).to be_falsey
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
          expect(controller.show_cookie_banner?).to be_truthy
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
      it 'returns truthy' do
        expect(controller.allow_analytics?).to be_truthy
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
end
