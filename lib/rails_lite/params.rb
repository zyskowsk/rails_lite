require 'uri'

class Params
  attr_reader :params

  def initialize(req, route_params)
    @params = {}
    parse_www_encoded_form(req.query_string)
  end

  def [](key)
    @params[key]
  end

  def to_s
     @params.to_s

    # query_array = []
    # @params.each do |key, value|
    #   query_array << "#{key}=#{value}"
    # end
    # query_array.join("&")
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    query_data = URI::decode_www_form(www_encoded_form)
    query_data.each do |pair|
      key, value = pair.first, pair.last
      @params[key] = value
    end
  end

  def parse_key(key)
  end
end
