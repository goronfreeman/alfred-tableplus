require_relative 'lib/alfred-workflow-ruby/alfred-3_workflow'
require_relative 'lib/plist/plist'

module AlfredTablePlus
  class Browse
    SUPPORTED_DBS = %w[mysql postgresql sqlite].freeze

    attr_reader :workflow, :connections

    def initialize
      @workflow = Alfred3::Workflow.new
      plist = "#{ENV['HOME']}/Library/Application Support/com.tinyapp.TablePlus/Data/Connections.plist"
      @connections = Plist.parse_xml(plist)
    end

    def open
      connections.empty? ? empty_json : output_json
      print workflow.output
    end

    def supported_driver?(driver)
      SUPPORTED_DBS.include?(driver)
    end

    def build_connection_string(driver, connection)
      return connection['DatabasePath'] if driver == 'sqlite'

      host = connection['DatabaseHost']
      db_name = connection['DatabaseName']
      user = connection['DatabaseUser']

      "#{driver}://#{user}@#{host}/#{db_name}"
    end

    def output_json
      connections.each do |connection|
        driver = connection['Driver'].downcase
        next unless supported_driver?(driver)
        connection_string = build_connection_string(driver, connection)

        workflow.result
                .uid(connection['ID'])
                .title(connection['ConnectionName'])
                .subtitle(connection['DatabaseName'])
                .arg(connection_string)
                .icon("img/#{driver}.png")
                .text('copy', connection_string)
                .autocomplete(connection['ConnectionName'])
      end
    end

    def empty_json
      workflow.result
              .title('No database connections available!')
              .subtitle('Open TablePlus to add a database connection')
              .arg('-a TablePlus')
    end
  end
end

AlfredTablePlus::Browse.new.open
