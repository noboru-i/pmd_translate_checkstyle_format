require 'thor'

module PmdTranslateCheckstyleFormat
  class CLI < Thor
    include ::PmdTranslateCheckstyleFormat::Translate
    desc 'translate', 'Exec Translate'
    option :data
    option :file
    option 'cpd-translate', type: :boolean
    def translate
      data = fetch_data(options)
      xml = parse(data)
      if options['cpd-translate']
        checkstyle = trans_cpd(xml)
      elsif
        checkstyle = trans(xml)
      end
      checkstyle.write(STDOUT, 2)
    end

    no_commands do
      def fetch_data(options)
        data = \
          if options[:data]
            options[:data]
          elsif options[:file]
            File.read(options[:file])
          elsif !$stdin.tty?
            ARGV.clear
            ARGF.read
          end

        fail NoInputError if !data || data.empty?

        data
      end
    end
  end
end
