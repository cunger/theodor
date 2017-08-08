require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'src/list'
require_relative 'src/item'

configure do
  enable :sessions
  set :session_secret, 'fnord' 
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

#### Routes

# GET  /lists         -> show all lists
# POST /lists         -> create a new list

# GET  /list/name     -> show the list 'name' with its items
# POST /list/name/new -> form for adding a new item to the list 'name'
# GET  /lists/new     -> form for creating a new list

####

get '/lists/?' do
  @lists = session[:lists]
  erb :lists
end

post '/lists' do
  session[:lists] << ToDo::List.new(params['list_name'])
  session[:success] = "New list '#{params['list_name']}' was created."
  redirect '/lists'
end

get '/lists/new' do
  erb :new_list
end

get '/lists/:id' do
  @list = find_list params['id']
  erb :list
end

get '/lists/:id/new' do
  @list = find_list params['id']
  erb :new_item
end

post '/lists/:id' do
  @list = find_list params['id']
  @list << ToDo::Item.new(params['item_name'])

  session[:success] = "New item '#{params['item_name']}' was added."
  redirect '/lists/' + params['id']
end

def find_list(id)
  session[:lists].select { |list| list.path == id }
                 .fetch(0) { halt 404 }
end
