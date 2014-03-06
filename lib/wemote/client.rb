module Wemote
  class Client

    def self.technique
      @technique ||= begin
        constants.collect {|const_name| const_get(const_name)}.select {|const| const.class == Module}.detect do |mod|
          fulfilled = false
          begin
            mod.const_get(:DEPENDENCIES).map{|d|require d}
            fulfilled = true
          rescue LoadError
          end
          fulfilled
        end
      end
    end

    module Manticore
      DEPENDENCIES = ['manticore']

      def get(url,body=nil,headers=nil)
        ::Manticore.get(url,{body:body,headers:headers}).call
      end

      def post(url,body=nil,headers=nil)
        ::Manticore.post(url,{body:body,headers:headers}).call
      end

    end

    module Typhoeus
      DEPENDENCIES = ['typhoeus']

      def get(url,body=nil,headers=nil)
        ::Typhoeus.get(url,{body:body,headers:headers})
      end

      def post(url,body=nil,headers=nil)
        ::Typhoeus.post(url,{body:body,headers:headers})
      end

    end

    module HTTParty
      DEPENDENCIES = ['httparty']

      def get(url,body=nil,headers=nil)
        ::HTTParty.get(url,{body:body,headers:headers})
      end

      def post(url,body=nil,headers=nil)
        ::HTTParty.post(url,{body:body,headers:headers})
      end
    end

    module NetHTTP
      DEPENDENCIES = ['net/http','uri']

      def get(url,body=nil,headers=nil)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        headers.map{|k,v|request[k]=v} if headers
        response = http.request(request)
      end

      def post(url,body=nil,headers=nil)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        headers.map{|k,v|request[k]=v} if headers
        (request.body = body) if body
        response = http.request(request)
      end
    end

    def initialize
      extend Wemote::Client.technique
    end

  end
end
