require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'example'

get '/' do
  redirect '/lists'
end

get '/lists/?' do
  @lists = EXAMPLES
  erb :all_lists
end

get '/lists/:id/?' do
  id = Integer params['id']
  halt 404 if id > EXAMPLES.size

  @list = EXAMPLES[id]
  erb :list
end

EXAMPLES = [ ToDo::Example.get_your_shit_together,
             ToDo::Example.build_a_rocket ]
