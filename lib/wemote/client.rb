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

      def get(*args)
        _get(::Manticore,*args).call
      end

      def post(*args)
        _post(::Manticore,*args).call
      end

    end

    module Typhoeus
      DEPENDENCIES = ['typhoeus']

      def get(*args)
        _get(::Typhoeus,*args)
      end

      def post(*args)
        _post(::Typhoeus,*args)
      end

    end

    module HTTParty
      DEPENDENCIES = ['httparty']

      def get(*args)
        _get(::HTTParty,*args)
      end

      def post(*args)
        _post(::HTTParty,*args)
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

    private

    def _get(lib,url,body=nil,headers=nil)
      lib.get(url,{body:body,headers:headers})
    end

    def _post(lib,url,body=nil,headers=nil)
      lib.post(url,{body:body,headers:headers})
    end

  end
end
