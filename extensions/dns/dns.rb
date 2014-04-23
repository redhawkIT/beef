#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Dns

      # @todo Add option for configuring upstream servers.

      # Provides the core DNS nameserver functionality. The nameserver handles incoming requests
      # using a rule-based system. A list of user-defined rules is used to match against incoming
      # DNS requests. These rules generate a response that is either a resource record or a
      # failure code.
      class Server < RubyDNS::Server

        include Singleton

        def initialize
          super()
          @lock = Mutex.new
        end

        # Adds a new DNS rule. If the rule already exists, its current ID is returned.
        #
        # @example Adds an A record for browserhacker.com with the IP address 1.2.3.4
        #
        #   dns = BeEF::Extension::Dns::Server.instance
        #
        #   id = dns.add_rule(
        #     :pattern  => 'browserhacker.com',
        #     :resource => Resolv::DNS::Resource::IN::A,
        #     :response => '1.2.3.4'
        #   )
        #
        # @param rule [Hash] hash representation of rule
        # @option rule [String, Regexp] :pattern match criteria
        # @option rule [Resolv::DNS::Resource::IN] :resource resource record type
        # @option rule [String, Array] :response server response
        #
        # @return [String] unique 8-digit hex identifier
        def add_rule(rule = {})
          @lock.synchronize do
            # Temporarily disable warnings regarding IGNORECASE flag
            verbose = $VERBOSE
            $VERBOSE = nil
            pattern = Regexp.new(rule[:pattern], Regexp::IGNORECASE)
            $VERBOSE = verbose

            BeEF::Core::Models::Dns::Rule.first_or_create(
              { :resource => rule[:resource], :pattern => pattern.source },
              { :response => rule[:response] }
            ).id
          end
        end

        # Retrieves a specific rule given its identifier.
        #
        # @param id [Integer] unique identifier for rule
        #
        # @return [Hash] hash representation of rule (empty hash if rule wasn't found)
        def get_rule(id)
          @lock.synchronize do
            rule = BeEF::Core::Models::Dns::Rule.get(id)
            hash = {}

            unless rule.nil?
              hash[:id] = rule.id
              hash[:pattern] = rule.pattern
              hash[:resource] = rule.resource
              hash[:response] = rule.response
            end

            hash
          end
        end

        # Entry point for processing incoming DNS requests. Attempts to find a matching rule and
        # sends back its associated response.
        #
        # @param name [String] name of the resource record being looked up
        # @param resource [Resolv::DNS::Resource::IN] query type (e.g. A, CNAME, NS, etc.)
        # @param transaction [RubyDNS::Transaction] internal RubyDNS class detailing DNS question/answer
        def process(name, resource, transaction)
          @lock.synchronize do
            transaction.respond!('1.1.1.1')
          end
        end

      end

    end
  end
end
