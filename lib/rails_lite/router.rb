class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
                pattern, http_method, controller_class, action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == @http_method &&
      !!(req.request_uri.request_uri =~ Regexp.new(@pattern))
  end

  def run(req, res)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      @routes << Route.new(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end

    nil
  end

  def run(req, res)
    if match(req).nil?
      res.status = 404
    else
      route = match(req)
      route_params = {}
      matches = Regexp.new(route.pattern).match(req.request_uri.request_uri)
      matches.names.each do |name|
        route_params[name.to_sym] = matches[name]
      end
      route.controller_class.new(
        req,
        res, 
        route_params
      ).invoke_action(route.action_name)
    end
  end
end
