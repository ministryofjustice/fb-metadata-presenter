class MetadataPresenter::Service < MetadataPresenter::Metadata
  def pages
    @_pages ||= metadata.pages.map { |page| MetadataPresenter::Page.new(page) }
  end

  def start_page
    pages.first
  end

  def find_page(path)
    pages.find { |page| page.url == path }
  end

  def next_page(from:)
    current_page = find_page(from)
    pages[pages.index(current_page) + 1] if current_page.present?
  end
end
