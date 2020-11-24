class MetadataPresenter::Page
  attr_reader :page

  def initialize(page)
    @page = page
  end

  def ==(other)
    id == other.id
  end

  def id
    page['_id']
  end

  def type
    page['_type']
  end

  def body
    page['body']
  end

  def lede
    page['lede']
  end

  def heading
    page['heading']
  end

  def section_heading
    page['section_heading']
  end

  def heading_class
    ''
  end

  def url
    page['url']
  end

  def steps
    page['steps']
  end

  def components
    # at some point
  end

  def template
    page['_type'].gsub('.', '/')
  end
end
