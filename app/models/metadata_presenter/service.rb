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
    # TODO: Add error handling in the case there is no next page
    pages[pages.index(find_page(from)) + 1]
  end
end
