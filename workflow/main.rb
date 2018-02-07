require_relative 'lib/alfred-workflow-ruby/alfred-3_workflow'
require_relative 'lib/plist/plist'

module AlfredTablePlus
  class Browse
    SUPPORTED_DBS = %w(mysql postgresql sqlite).freeze

    attr_reader :workflow, :path, :connections

    def initialize
      @workflow = Alfred3::Workflow.new
      @path = "#{ENV['HOME']}/Library/Application Support/com.tinyapp.TablePlus/Data/Connections.plist"
      @connections = Plist.parse_xml(path)
    end

    def open
      output_json
      print workflow.output
    end

    def supported_adapter?(adapter)
      SUPPORTED_DBS.include?(adapter)
    end

    def build_connection_string(adapter, connection)
      return connection['DatabasePath'] if adapter == 'sqlite'

      host = connection['DatabaseHost']
      db_name = connection['DatabaseName']
      user = connection['DatabaseUser']

      "#{adapter}://#{user}@#{host}/#{db_name}"
    end

    def output_json
      connections.each do |connection|
        adapter = connection['Driver'].downcase
        next unless supported_adapter?(adapter)
        connection_string = build_connection_string(adapter, connection)

        workflow.result
                .uid(connection['ID'])
                .title(connection['ConnectionName'])
                .subtitle(connection['DatabaseName'])
                .arg(connection_string)
                .text('copy', connection_string)
                .autocomplete(connection['ConnectionName'])
      end
    end
  end
end

AlfredTablePlus::Browse.new.open
