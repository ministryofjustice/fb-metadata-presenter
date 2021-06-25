class MetadataPresenter::Service < MetadataPresenter::Metadata
  def pages
    @pages ||= metadata.pages.map do |page|
      MetadataPresenter::Page.new(page, editor: editor?)
    end
  end

  def flow(page_uuid)
    MetadataPresenter::Flow.new(metadata.flow[page_uuid])
  rescue StandardError
    nil
  end

  def standalone_pages
    @standalone_pages ||= metadata.standalone_pages.map do |page|
      MetadataPresenter::Page.new(page, editor: editor?)
    end
  end

  def start_page
    pages.first
  end

  def service_slug
    service_name.parameterize
  end

  def find_page_by_url(url)
    all_pages.find { |page| strip_slash(page.url) == strip_slash(url) }
  end

  def find_page_by_uuid(uuid)
    all_pages.find { |page| page.uuid == uuid }
  end

  def next_page(from:)
    current_page = find_page_by_url(from)
    pages[pages.index(current_page) + 1] if current_page.present?
  end

  def previous_page(current_page:, referrer:)
    unless no_back_link?(current_page)
      flow_page(current_page) || referrer_page(referrer)
    end
  end

  def confirmation_page
    @confirmation_page ||= pages.find do |page|
      page.type == 'page.confirmation'
    end
  end

  def meta
    MetadataPresenter::Meta.new(configuration['meta'])
  end

  private

  def all_pages
    @all_pages ||= pages + standalone_pages
  end

  def no_back_link?(current_page)
    current_page == start_page || current_page == confirmation_page
  end

  def flow_page(current_page)
    page_index = pages.index(current_page)
    pages[page_index - 1] if page_index.present?
  end

  def referrer_page(referrer)
    find_page_by_url(URI(referrer).path) if referrer
  end

  def strip_slash(url)
    return url if url == '/'

    url.gsub(/^\//, '')
  end
end
