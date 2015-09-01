require 'nori'
require 'rexml/document'
require 'pathname'

module PmdTranslateCheckstyleFormat
  module Translate
    def parse(xml)
      Nori
        .new(parser: :rexml)
        .parse(xml)
    end

    def trans(xml)
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new('1.0', 'UTF-8')

      checkstyle = doc.add_element("checkstyle")
      if xml['pmd'].blank? || xml['pmd']['file'].blank?
        return doc
      end

      files = xml['pmd']['file']
      files = [files] if files.is_a?(Hash)
      files.each do |file|
        violations = file['violation']
        violations = [violations] unless violations.is_a?(Array)
        violations.each do |violation|
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

    def trans_cpd(xml)
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new('1.0', 'UTF-8')

      checkstyle = doc.add_element("checkstyle")
      if xml['pmd_cpd'].blank? || xml['pmd_cpd']['duplication'].blank?
        return doc
      end

      duplications = xml['pmd_cpd']['duplication']
      duplications = [duplications] if duplications.is_a?(Hash)
      duplications.each do |duplication|
        files = duplication['file']
        files = [files] unless files.is_a?(Array)
        files.each do |file|
          file_element = checkstyle.add_element("file", {
            'name' => file['@path']
            })
          file_element.add_element("error", {
            'line' => file['@line'],
            'severity' => 'error',
            'message' => create_cpd_message(duplication, file)
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

    def create_cpd_message(duplication, file)
      files = duplication['file'].reject { |item| item == file }
      file_names = files.map { |item|
        Pathname.new(item['@path']).relative_path_from(Pathname.new(Dir.pwd)).to_s
      }
      "[PMD-CPD] #{duplication['@lines']} lines duplicated.\n#{file_names.join("\n")}"
    end
  end
end
