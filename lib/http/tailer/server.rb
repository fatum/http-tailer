require 'json'
require 'eventmachine'
require 'eventmachine-tail'

module Http
  module Tailer
    def register(connection)
      @_connection = connection
    end
    module_function :register

    def connection
      @_connection
    end
    module_function :connection

    def registered?
      @_connection != nil
    end
    module_function :registered?

    class Reader < EventMachine::FileTail
      def initialize(path, startpos=-1)
        super(path, startpos)
        puts "[READER] Tailing #{path}"
        puts "[READER] Connection: #{Http::Tailer.registered?}"

        @buffer = BufferedTokenizer.new
      end

      def receive_data(data)
        return unless Http::Tailer.registered?

        @buffer.extract(data).each do |line|
          json = {path: path, line: line}.to_json
          puts "[READER]: #{json}"
          Http::Tailer.connection.send_data(json + "\n")
        end
      end
    end

    class Server < EventMachine::Connection
      def post_init
        puts "[SERVER]: Register server"

        Http::Tailer.register(self)
      end

      def receive_data(data)
        EventMachine.stop if data =~ /exit/
      end
    end
  end
end
