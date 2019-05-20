require_relative 'lib/alfred-workflow-ruby/alfred-3_workflow'
require_relative 'lib/plist/plist'

module AlfredTablePlus
  class Browse
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

    def output_json
      connections.each do |connection|
        driver = connection['Driver'].downcase
        connection_string = "tableplus://?id=" + connection['ID']

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
