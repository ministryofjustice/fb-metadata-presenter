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

  def previous_page(current_page:)
    pages[pages.index(current_page) - 1] unless current_page == start_page
  end

  def all_components
    pages.map(&:components).compact.flatten
  end

  def confirmation_page
    @confirmation_page ||= pages.find do |page|
      page.type == 'page.confirmation'
    end
  end
end
