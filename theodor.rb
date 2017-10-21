require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'src/list'
require_relative 'src/item'
require_relative 'src/session_persistence'

configure do
  enable :sessions
  set :erb, :escape_html => true
end

before do
  @storage = SessionPersistence.new(session)
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
  @lists = @storage.lists
  erb :lists
end

post '/lists' do
  @storage.add_list(params['list_name']) { or_invalid_list_name(:new_list) }
  session[:success] = "New list '#{list_name}' was created."
  redirect '/lists'
end

get '/lists/new' do
  erb :new_list
end

get '/lists/:id' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  erb :list
end

get '/lists/:id/new' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  erb :new_item
end

post '/lists/:id/done' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  @list.done!
  session[:success] = 'All items were marked done.'
  redirect "/lists/#{id}"
end

get '/lists/:id/rename' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  erb :rename_list
end

post '/lists/:id/rename' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  @storage.rename_list(@list, params['list_name']) { or_invalid_list_name(:rename_list) }
  session[:success] = 'List was renamed.'
  @lists = @storage.lists
  redirect '/lists'
end

post '/lists/:id' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  @storage.add_item(@list, params['item_name']) { or_invalid_item_name(:new_item) }
  session[:success] = "New item '#{item_name}' was added."
  redirect "/lists/#{id}"
end

get '/lists/:id/delete' do |id|
  @list = @storage.find_list(id) { or_list_not_found }
  erb :delete_list
end

post '/lists/:id/delete' do |id|
  @storage.delete_list(id) { or_list_not_found }
  session[:success] = "List '#{@list.name}' was deleted."
  redirect '/lists'
end

post '/lists/:list_id/:item_id/delete' do |list_id, item_id|
  @storage.delete_item(list_id, item_id) { or_list_not_found }
  session[:success] = 'Item was deleted.'
  redirect "/lists/#{list_id}"
end

post '/lists/:list_id/:item_id' do |list_id, item_id|
  @storage.toggle_item(list_id, item_id, params['done']) { or_list_not_found }
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

def or_list_not_found
  session[:error] = 'List was not found.'
  redirect '/lists'
end

def or_invalid_list_name(template)
  or_invalid_name('list', template)
end

def or_invalid_item_name(template)
  or_invalid_name('item', template)

def or_invalid_name(thing, template)
  session[:error] = "Invalid #{thing} name."
  halt erb(template)
end
