#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# This module is a modified version of RubyDNS built to be compatible with BeEF.
# For the most part, it will behave exactly the same except where otherwise noted.
#
# Additional features include database support, BeEF logger, assignment of unique
# identifiers to rules, rule removal, and more.
#
# The core functionality of BeEF's DNS server is implemented here, whereas
# BeEF::Extension::DNS::DNS is simply a small wrapper around it.
#
# @see http://rubydoc.info/gems/rubydns/frames
module RubyDNS

  # Behaves exactly the same, except without any logger output
  def self.run_server(options = {}, &block)
    server = RubyDNS::Server.new(&block)

    options[:listen] ||= [[:udp, "0.0.0.0", 53], [:tcp, "0.0.0.0", 53]]

    EventMachine.run do
      server.fire(:setup)

      options[:listen].each do |spec|
        if spec[0] == :udp
          EventMachine.open_datagram_socket(spec[1], spec[2], UDPHandler, server)
        elsif spec[0] == :tcp
          EventMachine.start_server(spec[1], spec[2], TCPHandler, server)
        end
      end

      server.load_rules
      server.fire(:start)
    end

    server.fire(:stop)
  end

  class Server

    class Rule

      # XXX Can this be removed?
      attr_accessor :id

      # Now uses an 'id' parameter to uniquely identify rules
      def initialize(id, pattern, callback)
        @id = id
        @pattern  = pattern
        @callback = callback
      end

    end

    # Now includes BeEF database support and checks for already present rules
    def match(*pattern, block)
      id = ''

      catch :match do
        begin
          # Sourcify block (already a string only for RESTful API calls)
          block_src = case block
                      when String then block
                      when Proc   then block.to_source
                      end

          # Break out and return id if rule is already present
          BeEF::Core::Models::DNS::Rule.each do |rule|
            if pattern[0] == rule.pattern \
                && pattern[1] == rule.type \
                && block_src == rule.block

              id = rule.id
              throw :match
            end
          end

          id = generate_id

          case block.class.name
          when String
            @rules << Rule.new(id, pattern, eval(block_src))
          when Proc
            @rules << Rule.new(id, pattern, block)
          end

          BeEF::Core::Models::DNS::Rule.create(
            :id => id,
            :pattern => pattern[0],
            :type => pattern[1],
            :block => block_src
          )
        rescue Sourcify::CannotHandleCreatedOnTheFlyProcError,
               Sourcify::CannotParseEvalCodeError,
               Sourcify::MultipleMatchingProcsPerLineError,
               Sourcify::NoMatchingProcError,
               Sourcify::ParserInternalError

          @logger.error "Failed to sourcify block for DNS rule '#{id}'"
          raise
        end
      end

      id
    end

    # New method that removes a rule given its id
    def remove_rule(id)
      @rules.delete_if { |rule| rule.id == id }

      begin
        BeEF::Core::Models::DNS::Rule.get!(id).destroy
      rescue DataMapper::ObjectNotFoundError => e
        @logger.error(e.message)
      end
    end

    # New method that loads all rules from the database at server startup
    def load_rules
      BeEF::Core::Models::DNS::Rule.each do |rule|
        id = rule.id
        pattern = [rule.pattern, rule.type]
        block = eval rule.block

        @rules << Rule.new(id, pattern, block)
      end
    end

    # New method that returns the entire DNS ruleset as an AoH
    def get_ruleset
      result = []

      BeEF::Core::Models::DNS::Rule.each do |rule|
        element = {}

        element[:id] = rule.id
        element[:pattern] = rule.pattern
        element[:type] = rule.type
        element[:block] = rule.block

        result << element
      end

      result
    end

    # New method that returns a hash representing the given rule
    def get_rule(id)
      result = {}

      begin
        rule = BeEF::Core::Models::DNS::Rule.get!(id)

        result[:id] = rule.id
        result[:pattern] = rule.pattern
        result[:type] = rule.type
        result[:block] = rule.block
      rescue DataMapper::ObjectNotFoundError => e
        @logger.error(e.message)
      end

      result
    end

    private

    # New method that generates a unique id for a rule
    def generate_id
      begin
        id = BeEF::Core::Crypto::secure_token.byteslice(0..6)

        # Make sure id isn't already in use
        BeEF::Core::Models::DNS::Rule.each { |rule| throw StandardError if id == rule.id }
      rescue StandardError
        retry
      end

      id
    end

  end

  class Transaction

    # Behaves exactly the same, except using debug logger instead of info
    def respond!(*data)
      options = data.last.kind_of?(Hash) ? data.pop : {}
      resource_class = options[:resource_class] || @resource_class
			
      if resource_class == nil
        raise ArgumentError, "Could not instantiate resource #{resource_class}!"
      end
			
      @server.logger.debug("Resource class: #{resource_class.inspect}")
      resource = resource_class.new(*data)
      @server.logger.debug("Resource: #{resource.inspect}")
			
      append!(resource, options)
    end

  end

end
