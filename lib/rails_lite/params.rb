require 'uri'

class Params
  attr_reader :params

  def initialize(req, route_params)
    @params = route_params
    parse_www_encoded_form(req.query_string) unless req.query_string.nil?
    parse_www_encoded_form(req.body) unless req.body.nil?
  end

  def [](key)
    @params[key]
  end

  def to_s
     @params.to_json
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    query_data = URI::decode_www_form(www_encoded_form)
    query_data.each do |pair|
      keys, value = parse_key(pair.first), pair.last
      @params[keys.first] = parse_nested_key(keys, value).values.first
    end
  end

  def parse_key(key)
    key.scan(/(\w+)/).flatten
  end

  def parse_nested_key(keys, value)
    current_hash = {}
    current_hash[keys.pop] = value
    until keys.empty?
      new_hash = {}
      new_hash[keys.pop] = current_hash
      current_hash = new_hash
    end

    current_hash
  end
end


