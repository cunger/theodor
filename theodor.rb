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

# GET  /lists            -> show all lists
# GET  /lists/new        -> form for creating a new list
# POST /lists            -> create a new list

# GET  /list/name        -> show the list 'name' with its items
# POST /list/name/new    -> form for adding a new item to the list 'name'
# GET  /list/name/rename -> form for renaming the list 'name'
# POST /list/name/rename -> rename the list 'name'
# GET  /list/name/delete -> ask to delete the list 'name'
# POST /list/name/delete -> delete the list 'name'

####

get '/lists/?' do
  @lists = session[:lists]
  erb :lists
end

post '/lists' do
  list_name = truncate params['list_name'].strip
  error_message = error_for(list_name, session[:lists], 'list', 'name')
  if error_message
    session[:error] = error_message
    erb :new_list
  else
    session[:lists] << ToDo::List.new(list_name)
    session[:success] = "New list '#{list_name}' was created."
    redirect '/lists'
  end
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

get '/lists/:id/rename' do
  @list = find_list params['id']
  erb :rename_list
end

post '/lists/:id/rename' do
  @list = find_list params['id']
  list_name = truncate params['list_name'].strip
  error_message = error_for(list_name, session[:lists], 'list', 'name')
  if error_message
    session[:error] = error_message
    erb :rename_list
  else
    session[:success] = "List was renamed."
    @list.name = list_name
    @lists = session[:lists]
    redirect '/lists'
  end
end

post '/lists/:id' do
  @list = find_list params['id']
  item_name = truncate params['item_name'].strip
  error_message = error_for(item_name, @list.items, 'item', 'description')
  if error_message
    session[:error] = error_message
    erb :new_item
  else
    @list << ToDo::Item.new(item_name)
    session[:success] = "New item '#{item_name}' was added."
    redirect '/lists/' + params['id']
  end
end

get '/lists/:id/delete' do
  @list = find_list params['id']
  erb :delete_list
end

post '/lists/:id/delete' do
  @list = find_list params['id']
  @lists = session[:lists]
  @lists.delete @list
  session[:success] = "List '#{@list.name}' was deleted."
  redirect '/lists'
end

private

def find_list(id)
  session[:lists].select { |list| list.path == id }
                 .fetch(0) { halt 404 }
end

def truncate(string, length=100)
  string.size > length ? string.slice(0, length - 3) + '...' : string
end

def error_for(name, collection, thing, attribute)
  if name.empty?
    "#{thing.capitalize} #{attribute} cannot be empty."
  elsif !unique?(name, collection)
    "You already have some #{thing} with this #{attribute}."
  end
end

def unique?(name, collection)
  collection.none? { |element| element.name == name }
end
