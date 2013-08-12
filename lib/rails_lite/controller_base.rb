require 'erb'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(@req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    @res.status = "302"
    @res["Location"]= "#{url}"
    @response_built = true
    session.store_session(@res)
  end

  def render_content(body, content_type)
    @res.content_type = content_type
    @res.body = body
    @already_rendered = true
    session.store_session(@res)
  end

  def render(action_name)
    controller_name = self.class.to_s.underscore
    view = File.read("views/#{controller_name}/#{action_name.to_s}.html.erb")
    template = ERB.new(view)
    result = template.result(binding)

    render_content(result, "text/html")
  end

  def invoke_action(name)
  end
end
