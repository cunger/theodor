require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'src/list'
require_relative 'src/item'

configure do
  enable :sessions
  set :session_secret, 'fnord' # fine for now only because the session cookie
                               # doesn't store any sensitive information
  set :erb, :escape_html => true
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

# GET  /lists/name        -> show the list 'name' with its items
# POST /lists/name/new    -> form for adding a new item to the list 'name'
# POST /lists/name/done   -> mark all items in the list 'name' as done
# GET  /lists/name/rename -> form for renaming the list 'name'
# POST /lists/name/rename -> rename the list 'name'
# GET  /lists/name/delete -> ask to delete the list 'name'
# POST /lists/name/delete -> delete the list 'name'

# POST /lists/name/item/delete     -> delete item from list 'name'
# POST /lists/name/item?done=true  -> set item on list 'name' to done
# POST /lists/name/item?done=false -> set item on list 'name' to not done

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

get '/lists/:id' do |id|
  @list = find_list id
  erb :list
end

get '/lists/:id/new' do |id|
  @list = find_list id
  erb :new_item
end

post '/lists/:id/done' do |id|
  @list = find_list id
  @list.done!
  session[:success] = 'All items were marked done.'
  redirect "/lists/#{id}"
end

get '/lists/:id/rename' do |id|
  @list = find_list id
  erb :rename_list
end

post '/lists/:id/rename' do |id|
  @list = find_list id
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

post '/lists/:id' do |id|
  @list = find_list id
  item_name = truncate params['item_name'].strip
  error_message = error_for(item_name, @list.items, 'item', 'description')
  if error_message
    session[:error] = error_message
    erb :new_item
  else
    @list << ToDo::Item.new(item_name)
    session[:success] = "New item '#{item_name}' was added."
    redirect "/lists/#{id}"
  end
end

get '/lists/:id/delete' do |id|
  @list = find_list id
  erb :delete_list
end

post '/lists/:id/delete' do |id|
  @list = find_list id
  @lists = session[:lists]
  @lists.delete @list
  session[:success] = "List '#{@list.name}' was deleted."
  redirect '/lists'
end

post '/lists/:list_id/:item_id/delete' do |list_id, item_id|
  @list = find_list list_id
  @list.items.delete_at Integer(item_id)
  session[:success] = "Item was deleted."
  redirect "/lists/#{list_id}"
end

post '/lists/:list_id/:item_id' do |list_id, item_id|
  @list = find_list list_id
  item = Integer(item_id)
  if params['done']
    params['done'] == 'true' ? @list[item].done! : @list[item].undone!
  end
  redirect "/lists/#{list_id}"
end

helpers do
  def html(content)
    Rack::Utils.escape_html(content)
  end

  def re_order(collection)
    collection.partition { |element| !element.done? }.flatten
  end
end

private

def find_list(id)
  session[:lists].select { |list| list.path == id }.fetch(0) do
    session[:error] = 'List was not found.'
    redirect '/lists'
  end
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
