module MetadataPresenter
  module SpecialCharacterUnescaper
    SPECIAL_CHARACTER_MAPPING = {
      '&amp;' => '&',
      '\u0026' => '&',
      '&lt;' => '<',
      '&gt;' => '>'
    }.freeze

    def unescape_special_characters(text)
      pattern = Regexp.union(SPECIAL_CHARACTER_MAPPING.keys)
      text&.gsub(pattern) { |m| SPECIAL_CHARACTER_MAPPING[m] }
    end
  end
end
