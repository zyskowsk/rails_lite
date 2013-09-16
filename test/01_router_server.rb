require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'rails_lite'
require 'debugger'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class StatusController < ControllerBase
  def index
    statuses = ["s1", "s2", "s3"]

    render_content(statuses.to_json, "text/json")
  end

  def show
    render_content("status ##{params[:id]}", "text/text")
  end

  def new
    render :new
  end
end

class UserController < ControllerBase
  def index
    users = ["u1", "u2", "u3"]
    flash[:messages] = "hello i am a flash"

    redirect_to('http://localhost:8080/statuses/new')
  end
end

server.mount_proc '/' do |req, res|
  router = Router.new
  router.draw do
    get Regexp.new("^/statuses$"), StatusController, :index
    get Regexp.new("^/users$"), UserController, :index
    get Regexp.new("^/statuses/new$"), StatusController, :new

    # uncomment this when you get to route params
   get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusController, :show
  end


  route = router.run(req, res)
end

server.start
