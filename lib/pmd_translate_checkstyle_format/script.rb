module PmdTranslateCheckstyleFormat
  class Script
    extend ::PmdTranslateCheckstyleFormat::Translate
    def self.translate(xml_text)
      trans(parse(xml_text)).to_s
    end

    def self.translate_cpd(xml_text)
      trans_cpd(parse(xml_text)).to_s
    end
  end
end
