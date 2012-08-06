require 'sinatra'
require 'json'
load 'parser.rb'
get '/' do
  'here'
end
get '/tomatoist/:username.json' do
  content_type :json
  @tomatoist_parser = Parser.new(params[:username])
  JSON.generate(@tomatoist_parser.pomodoros)
end