module Api
  class Apollo
    include HTTParty

    debug_output $stderr
    base_uri Rails.configuration.apollo_base_uri
    format :json

    def initialize(args)
      @parsed_response = Hashie::Mash.new(args[:parsed_response])
    end

    def self.default_params
      { uip: Rails.configuration.facility_ip }
    end

    def self.apollo_default_options
      {}
    end

    def self.find(id, params={}, options={})
      request_string = build_request_string(id, params, options)
      get = get(request_string)
      Rails.logger.debug "Apollo request: #{base_uri}#{request_string} Result: #{get.response}"
      handle_error(get.response.code) unless get.response.code == "200"
      if get.parsed_response["data"].kind_of?(Array)
        objects = []
        get.parsed_response["data"].each do |object|
          objects << self.new(parsed_response: object)
        end
        objects
      else
        self.new(parsed_response: get.parsed_response)
      end
    end

    def self.build_request_string(id, params={}, options={})
      options = apollo_default_options.merge(options)
      request_string  = ""
      request_string += "/#{options[:scope]}" if options[:scope] and !options[:scope].blank?
      request_string += "/#{resource_name}"
      request_string  = "#{request_string}/#{id}" unless id == :all
      query_string    = default_params.merge(params).collect{ |k,v| "#{k}=#{v}" }.join('&')
      request_string  = "#{request_string}?#{query_string}" unless query_string.blank?
      request_string
    end

    def self.resource_name
      name.split('::').last.underscore.pluralize
    end

    def self.handle_error(response_code)
      case response_code.to_i
      when 401
        raise Api::UnauthorizedError
      when 404
        raise Api::NotFoundError
      when 500..600
        raise Api::ServerError
      else
        raise Api::Error
      end
    end

    def method_missing(sym)
      return @parsed_response.send(sym)
    end
    
  end

  class Error < StandardError; end
  class UnauthorizedError < StandardError
    def to_s; "401 Unauthorized"; end
  end
  class NotFoundError < StandardError
    def to_s; "404 Not Found"; end
  end
  class ServerError < StandardError
    def to_s; "Server Error"; end
  end
end
