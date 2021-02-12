module MetadataPresenter
  class Page < MetadataPresenter::Metadata
    include ActiveModel::Validations

    def uuid
      _uuid
    end

    def ==(other)
      id == other.id if other.respond_to? :id
    end

    def editable_attributes
      self.to_h.reject { |k,_| k.in?([:_id, :_type, :steps]) }
    end

    def components
      metadata.components&.map do |component|
        MetadataPresenter::Component.new(component)
      end
    end

    def to_partial_path
      type.gsub('.', '/')
    end

    def template
      "metadata_presenter/#{type.gsub('.', '/')}"
    end
  end
end
