require 'typhoeus'
require 'json'
require 'hashie'

class GConnect
  GRANT_TYPE        = "refresh_token".freeze
  REFRESH_TOKEN_URL = "https://accounts.google.com/o/oauth2/token".freeze
  
  class Connection
    attr_reader   :client_id, :client_secret
    attr_accessor :callback_request_made, :callback_access_token_refreshed,
                  :hydra
    
    def initialize(options = {})
      @client        = options[:client_id]     || ENV['GOOGLE_KEY']
      @client_secret = options[:client_secret] || ENV['GOOGLE_SECRET']
      @hydra         = Typhoeus::Hydra.new
      
      @callback_request_made          = Proc.new {}
      @callback_access_token_refreshed = Proc.new {}
    end
    
    # This method is still ugly and could use some cleanup.
    def api(method, url, options = {})
      unless [:get, :delete, :post, :put, :patch].include? method
        raise "Unknown REST method: #{method}"
      end
      
      config = RequestConfig.new
      config.method = method
      config.access_token   = options[:access_token]
      config.request_params = options[:request_params]
      config.request_body   = options[:request_body]
      refresh_token         = options[:refresh_token]
      
      request = Typhoeus::Request.new url, config.finalize
      request.on_complete do |response|
        case
        when response.success?
          puts "Success"
          @callback_request_made.call
          return GConnect::Response.new response
        when response.timed_out?
          puts "Timed out.  Is google down?"
          return response
        when response.code == 401
          puts "In refresh block"
          if refresh_token && @client && @client_secret
            new_access_token = fetch_new_access_token(refresh_token)
            options.delete(:refresh_token)
            options[:access_token] = new_access_token
            return api(method, url, options)
          else
            return response
          end
        when response.code == 0
          puts"Could not get an http response, something's wrong."
          return response
        else
          puts "HTTP request failed: #{response.code}"
          return response
        end
      end
      
      @hydra.queue(request)
      @hydra.run
      
      request
    end
    
    def fetch_new_access_token(refresh_token)
      response = api :post, REFRESH_TOKEN_URL,
                     request_body: {
                       refresh_token: refresh_token,
                       grant_type:    GRANT_TYPE,
                       client_id:     @client,
                       client_secret: @client_secret
                     }
      @callback_access_token_refreshed.call response, refresh_token
      return response.body.access_token
    end
    
    def register_callback(callback, method)
      if callback == :request_made
        @callback_request_made = method
      elsif callback == :access_token_refreshed
        @callback_access_token_refreshed = method
      end
      method
    end
  end
  
  class RequestConfig < Hashie::Mash
    def access_token=(access_token)
      return self if access_token.nil?
      self.headers = {} if self.headers.nil?
      
      self.headers.Authorization = "Bearer #{access_token}"
      self
    end
    
    def request_params=(hash)
      return self if hash.nil?
      self.params = {} if self.params.nil?
      
      hash.each do |key, value|
        self.params[camelize_key(key)] = value
      end
      self
    end
    
    def request_body=(hash)
      return self if hash.nil?
      self._body = {} if self._body.nil?
      
      hash.each do |key, value|
        self._body[camelize_key(key)] = value
      end
      self
    end
    
    def finalize
      if self._body
        self.body = hash_to_body(self._body)
        self.delete(:_body)
      end
      symbolize_hash_keys self.to_hash
    end
      
    private
    
    def camelize_key(sym)
      return sym if protected_symbol(sym)
      sym.to_s.camelize(:lower).to_sym
    end
    
    def protected_symbol(sym)
      p = [:grant_type, :access_token, :refresh_token, :client_id, :client_secret]
      return true if p.include? sym
    end
    
    def hash_to_body(hash)
      hash.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end
    
    def symbolize_hash_keys(hash)
      hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end
  end
  
  class Response
    attr_reader :body
    
    def initialize(typhoeus_response)
      @body = Hashie::Mash.new JSON.parse(typhoeus_response.body) 
    end
  end
end