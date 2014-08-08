module Wemote
  class Client

    def self.technique
      @technique ||= begin
        constants.collect {|const_name| const_get(const_name)}.select {|const| const.class == Module}.detect do |mod|
          fulfilled = false
          begin
            next unless mod.const_defined?(:DEPENDENCIES)
            mod.const_get(:DEPENDENCIES).map{|d|require d}
            fulfilled = true
          rescue LoadError
          end
          fulfilled
        end
      end
    end

    module SmartLib
      %w{get post put}.each do |name|
        define_method name do |*args|
          _req(@lib,name,*args).tap{|r|r.call if @call}
        end
      end
    end

    module Manticore
      DEPENDENCIES = ['manticore']
      def self.extended(base)
        base.instance_variable_set(:@lib,::Manticore)
        base.instance_variable_set(:@call,true)
        base.extend(SmartLib)
      end
    end

    module Typhoeus
      DEPENDENCIES = ['typhoeus']
      def self.extended(base)
        base.instance_variable_set(:@lib,::Typhoeus)
        base.extend(SmartLib)
      end
    end

    # HTTParty is temporarily disabled, as it's auto-parsing the XML

    #module HTTParty
    #  DEPENDENCIES = ['httparty']
    #  def self.extended(base)
    #    base.instance_variable_set(:@lib,::HTTParty)
    #    base.extend(SmartLib)
    #  end
    #end

    module NetHTTP
      DEPENDENCIES = ['net/http','uri']

      def request(klass,url,body=nil,headers=nil)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = klass.new(uri.request_uri)
        headers.map{|k,v|request[k]=v} if headers
        (request.body = body) if body
        response = http.request(request)
      end

      %w{get post put}.each do |name|
        define_method name do |*args|
          request(Net::HTTP.const_get(name.capitalize),*args)
        end
      end

    end

    def initialize
      extend Wemote::Client.technique
    end

    private

    def _req(lib,method,url,body=nil,headers=nil)
      lib.send(method,url,{body:body,headers:headers})
    end

  end
end
