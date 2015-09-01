require 'nori'

module PmdTranslateCheckstyleFormat
  module Translate
    def parse(xml)
      Nori
        .new(parser: :rexml)
        .parse(xml)
    end

    def trans(xml)
      require 'rexml/document'
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new('1.0', 'UTF-8')

      checkstyle = doc.add_element("checkstyle")
      if xml['pmd'].blank? || xml['pmd']['file'].blank?
        # set_dummy(xml, checkstyle)
        return doc
      end

      files = xml['pmd']['file']
      files = [files] if files.is_a?(Hash)
      files.each do |file|
        violations = file['violation']
        violations = [violations] unless violations.is_a?(Array)
        violations.each do |violation|
          puts violation.attributes
          file_element = checkstyle.add_element("file", {
            'name' => file['@name']
            })
          file_element.add_element("error", {
            'line' => violation.attributes['beginline'],
            'severity' => get_severity(violation.attributes['priority'].to_i),
            'message' => "[#{violation.attributes['rule']}] #{violation.strip}\n#{violation.attributes['externalInfoUrl']}"
            })
        end
      end

      doc
    end

    def get_severity(priority)
      case priority
      when 1, 2
        'error'
      when 3, 4
        'warning'
      when 5
        'info'
      end
    end
  end
end
