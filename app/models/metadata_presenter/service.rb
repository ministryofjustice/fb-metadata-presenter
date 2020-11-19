class MetadataPresenter::Service
  attr_reader :raw_metadata

  def initialize(raw_metadata)
    @raw_metadata = raw_metadata
  end

  def service_id
    raw_metadata['service_id']
  end

  def service_name
    raw_metadata['service_name']
  end

  def version_id
    raw_metadata['version_id']
  end

  def created_at
    raw_metadata['created_at']
  end

  def created_by
    raw_metadata['created_by']
  end

  def pages
    raw_metadata['pages'].map do |page|
      MetadataPresenter::Page.new(page)
    end
  end

  def configuration
    raw_metadata['configuration']
  end

  def locale
    raw_metadata['locale']
  end

  def start_page
    pages.first
  end

  def render
    ApplicationController.render(template: 'service/start')
  end
end
