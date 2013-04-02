require 'typhoeus'
require 'json'
require 'hashie'

module GConnect
  GRANT_TYPE        = "refresh_token".freeze
  REFRESH_TOKEN_URL = "https://accounts.google.com/o/oauth2/token".freeze
  
  class Connection
    attr_reader :client_id, :client_secret
    attr_accessor :request_made_proc, :access_token_updated_proc
    
    def initialize(client_id = nil, client_secret = nil, params = {})
      @client_id     = client_id     || ENV['GOOGLE_KEY']
      @client_secret = client_secret || ENV['GOOGLE_SECRET']
      
      # Pass a proc or lambda to set up callbacks on these actions
      @request_made_proc         = params[:request_made_proc]
      @access_token_updated_proc = params[:access_token_updated_proc]
    end
    
    def api(url, method, params = {})
      typhoeus_options = {
        client_id:     @client_id,
        client_secret: @client_secret,
        access_token:  params[:access_token]
      }
      
      request = Typhoeus::Request.new url,
                  method: :get,
                  params: typhoeus_options
      
      request.on_complete do |response|
        case
        when response.success?
          puts "Success"
          @request_made_proc.call
          return GConnect::Response.new response
        when response.timed_out?
          puts "Timed out.  Is google down?"
          return response
        when response.code == 401
          # TODO: There is two situations when this occurs.  When we need a new
          # auth token and when we just don't send out the right credentials for
          # anything (ex: don't send any auth tokens or client_ids).  Figure out
          # how to distinguish between those two requests and properly get a new
          # token or just throw an error.
          puts "In refresh block"
          if params[:refresh_token]
            new_auth = fetch_new_access_token(params[:refresh_token])
            params[:access_token] = new_auth.body.access_token
            return api(url, method, params)
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
      
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      
      request
    end
    
    def fetch_new_access_token(refresh_token)
      puts "Fetch new access token"
      
      # Builds the params for getting a new access token
      post_params = {
        client_id:     @client_id,
        client_secret: @client_secret,
        refresh_token: refresh_token,
        grant_type:    GRANT_TYPE
      }
      
      # Prep the request
      request = Typhoeus::Request.new REFRESH_TOKEN_URL,
                  method: :post,
                  body: hash_to_body(post_params)
      
      request.on_complete do |response|
        response_obj = GConnect::Response.new response
        
        @request_made_proc.call
        @access_token_updated_proc.call(response_obj.body.access_token,
          refresh_token)
        
        return response_obj
      end
      
      # Run the request
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      
      response
    end
    
    private
    
    def hash_to_body(hash)
      hash.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end
  end
  
  class Response
    attr_reader :body
    
    def initialize(typhoeus_response)
      @body = Hashie::Mash.new JSON.parse(typhoeus_response.body) 
    end
  end
end