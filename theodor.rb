require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'src/list'
require_relative 'src/item'

configure do
  enable :sessions
  set :session_secret, 'fnord' # remove if you want to start new session
                               # every time the web service is re-started
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# GET  /lists           -> show all lists
# GET  /list/name       -> show the list 'name'
# GET  /list/name/items -> show all items in the list 'name'
# GET  /lists/new       -> form for creating a new list
# POST /lists           -> create a new list

get '/lists/?' do
  @lists = session[:lists]
  erb :lists
end

post '/lists' do
  session[:lists] << ToDo::List.new(params['list_name'])
  redirect '/lists'
end

get '/lists/new' do
  erb :new_list
end

get '/lists/:id/?' do
  @list = session[:lists].select { |list| list.path == params['id'] }
                         .fetch(0) { halt 404 }
  erb :list
end
