require_relative 'lib/alfred-workflow-ruby/alfred-3_workflow'
require_relative 'lib/plist/plist'

module AlfredTablePlus
  class Search
    attr_reader :workflow, :path, :connections

    def initialize
      @workflow = Alfred3::Workflow.new
      @path = "#{ENV['HOME']}/Library/Application Support/com.tinyapp.TablePlus/Data/Connections.plist"
      @connections = Plist.parse_xml(path)
    end

    def search
      output_json
      print workflow.output
    end

    def build_connection_string(connection)
      adapter = connection['Driver'].downcase
      host = connection['DatabaseHost']
      db_name = connection['DatabaseName']
      user = connection['DatabaseUser']

      "#{adapter}://#{user}@#{host}/#{db_name}"
    end

    def output_json
      connections.each do |connection|
        connection_string = build_connection_string(connection)

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

AlfredTablePlus::Search.new.search
