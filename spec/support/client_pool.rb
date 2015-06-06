module Cassanity
  class ClientPool

    def self.get_client(options = {})
      @client ||= Cassanity::Client.new(CassanityHost, CassanityPort, options)
    end

    def self.disconnect
      if @client
        @client.disconnect
        @client = nil
      end
    end

  end
end
