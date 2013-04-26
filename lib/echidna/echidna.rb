require 'typhoeus'
require 'json'
require 'hashie'

module Echidna 
  def self.configure
    yield Config
  end

  module Config
    extend self

    # Sets up the url to make a refresh token request too.
    attr_accessor :refresh_token_url

    # This will probably never change; but in cases
    def grant_type
      "refresh_token"
    end

    # Used to set the oauth auth hearder to either Bearer or bearer
    attr_writer :authorization_bearer
    def authorization_bearer
      @authorization_bearer || "Bearer"
    end

    # Your Oauth2 app key and secret and provider string
    attr_accessor :provider, :client_id, :client_secret

    # The two callbacks to fire when a request is made and when an new Oauth token
    # is issued.
    attr_accessor :callback_request_made, :callback_token_refreshed
  end

  class Connection
    attr_reader   :client_id, :client_secret, :refresh_token_url, :provider
    attr_accessor :callback_request_made, :callback_token_refreshed, 
                  :hydra
    
    def initialize(options = {})
      # Go through the configuration chain and set all the properties for this
      # connection
      @provider          = options[:provider] || Echidna::Config.provider
      @refresh_token_url = options[:refresh_token_url] || Echidna::Config.refresh_token_url
      @client_id         = options[:client_id] || Echidna::Config.client_id
      @client_secret     = options[:client_secret] || Echidna::Config.client_secret
      
      
      @callback_request_made = \
        options[:callback_request_made] ||
        Echidna::Config.callback_request_made ||
        Proc.new {}
      @callback_token_refreshed = \
        options[:callback_token_refreshed] ||
        Echidna::Config.callback_token_refreshed ||
        Proc.new {}

      # Sets up Hydra pool to use with this request
      @hydra = Typhoeus::Hydra.new
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
      config.content_type   = "application/json" unless url == @refresh_token_url
      config.form_encoding  = true if url == @refresh_token_url
      refresh_token         = options[:refresh_token]
      user_uid              = options[:user_uid]

      puts "*" * 88
      puts config.finalize.to_hash.inspect
      puts "*" * 88
      
      request = Typhoeus::Request.new url, config.finalize
      request.on_complete do |response|
        case
        when response.success?
          puts "Success"
          @callback_request_made.call
          return Echidna::Response.new response
        when response.timed_out?
          puts "Timed out.  Is google down?"
          return Echidna::Error.new response
        when response.code == 401
          puts "In refresh block"
          if refresh_token && @client_id && @client_secret
            new_access_token = fetch_new_access_token(user_uid, refresh_token)
            options.delete(:refresh_token)
            options[:access_token] = new_access_token
            return api(method, url, options)
          else
            return Echidna::Error.new response
          end
        when response.code == 0
          puts"Could not get an http response, something's wrong."
          return Echidna::Error.new response
        else
          puts "HTTP request failed: #{response.code}"
          return Echidna::Error.new response
        end
      end
      
      @hydra.queue(request)
      @hydra.run
      
      request
    end
    
    def fetch_new_access_token(user_uid, refresh_token)
      response = api :post, @refresh_token_url,
                     request_body: {
                       refresh_token: refresh_token,
                       grant_type:    Echidna::Config.grant_type,
                       client_id:     @client_id,
                       client_secret: @client_secret
                     }
      @callback_token_refreshed.call(provider, user_uid, response.body)
      return response.body.access_token
    end
    
    def register_callback(callback, method)
      if callback == :request_made
        @callback_request_made = method
      elsif callback == :token_refreshed
        @callback_token_refreshed = method
      end
      method
    end
  end
  
  class RequestConfig < Hashie::Mash
    attr_accessor :form_encoding
    
    def content_type=(content_type)
      return self if content_type.nil?
      self.headers = {} if self.headers.nil?
      
      self.headers[:'Content-Type'] = content_type
    end
    
    def access_token=(access_token)
      return self if access_token.nil?
      self.headers = {} if self.headers.nil?
      
      self.headers.Authorization = "#{Echidna::Config.authorization_bearer} #{access_token}"
      self
    end
    
    def request_params=(hash)
      return self if hash.nil?
      self.params = {} if self.params.nil?
      
      hash.each do |key, value|
        self.params[key] = value
      end
      self
    end
    
    def request_body=(hash)
      return self if hash.nil?
      self.body = {} if self.body.nil?
      
      hash.each do |key, value|
        self.body[key] = value
      end
      self
    end
    
    def finalize
      if self.body
        if @form_encoding
          self.body = hash_to_body(self.body)
        else
          self.body = self.body.to_json
        end
      end
      symbolize_hash_keys self.to_hash
    end
      
    private
    
    def hash_to_body(hash)
      return hash if hash.kind_of? String
      hash.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end
    
    def symbolize_hash_keys(value)
      case value
        when Array
          value.map { |v| symbolize_hash_keys(v) }
        when Hash
          Hash[value.map { |k, v| [k.to_sym, symbolize_hash_keys(v)] }]
        else
          value
       end
    end
  end
  
  class Response
    attr_reader :body, :code
    
    def initialize(response)
      @code = response.code
      @body = Hashie::Mash.new JSON.parse(response.body)
    end
  end
  
  class Error
    attr_reader :body, :code
    
    def initialize(response)
      @code = response.code
      begin
        @body = Hashie::Mash.new JSON.parse(response.body)
      rescue
        @body = response.body
      end
    end
  end
end