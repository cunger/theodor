require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  redirect '/lists'
end

get '/lists/?' do
  'All your todo lists.'
end
