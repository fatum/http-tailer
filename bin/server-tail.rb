#!/usr/bin/env ruby
#
# Simple 'tail -f' example.
# Usage example:
#   tail.rb /var/log/messages
require "rubygems"
require 'http/tailer'

def main(args)
  if args.length == 0
    puts "Usage: #{$0} <path> [path2] [...]"
    return 1
  end

  EventMachine.run do
    EventMachine.start_server("127.0.0.1", 9999, Http::Tailer::Server)

    args.each do |path|
      EventMachine::file_tail(path, Http::Tailer::Reader)
    end

    trap("INT")  { puts 'INT';  EventMachine.stop }
    trap("TERM") { puts 'TERM'; EventMachine.stop }
  end

  1
end

exit(main(ARGV))
