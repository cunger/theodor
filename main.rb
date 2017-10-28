require 'dotenv'
Dotenv.load

require 'sinatra'
require 'sysrandom/securerandom'

require_relative 'lib/database_connection'

configure do
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'lib/database_connection.rb'
end

before do
  @data ||= ToDo::DatabaseConnection.new('todos', logger)
end

after do
  @data.disconnect
end

#### Routes ####

## Show all lists

get '/' do
  redirect '/lists'
end

get '/lists/?' do
  @lists = @data.lists

  haml :lists
end

## Add a new list

get '/lists/new' do
  haml :new_list
end

post '/lists/new' do
  list_name = params['list_name']

  @data.add_list!(list_name) { or_invalid_list_name(:new_list) }

  session[:success] = "New list '#{list_name}' was created."
  redirect '/lists'
end

## Show a specific list

get '/lists/:list_id' do |list_id|
  @list = @data.find_list(list_id) { or_list_not_found }

  haml :list
end

## Rename the list

get '/lists/:list_id/rename' do |list_id|
  @list_id   = list_id
  @list_name = @data.find_list_name(list_id) { or_list_not_found }

  haml :rename_list
end

post '/lists/:list_id/rename' do |list_id|
  @data.rename_list!(list_id, params['list_name']) { or_invalid_list_name(:rename_list) }

  session[:success] = 'List was renamed.'
  redirect '/lists'
end

## Mark a list as done

post '/lists/:list_id/done' do |list_id|
  @data.mark_list_as_done!(list_id)

  session[:success] = 'All items were marked done.'
  redirect "/lists/#{list_id}"
end

## Delete a list

get '/lists/:list_id/delete' do |list_id|
  @list = @data.find_list(list_id) { or_list_not_found }

  haml :delete_list
end

post '/lists/:list_id/delete' do |list_id|
  @data.delete_list!(list_id)

  session[:success] = "List was deleted."
  redirect '/lists'
end

## Add an item to the list

get '/lists/:list_id/new' do |list_id|
  @list_id = list_id

  haml :new_item
end

post '/lists/:list_id/new' do |list_id|
  @data.add_item!(list_id, params['item_name']) { or_invalid_item_name(:new_item) }

  session[:success] = "New item was added."
  redirect "/lists/#{list_id}"
end

## Toggle an item done/undone

post '/lists/:list_id/:item_id/toggle' do |list_id, item_id|
  @data.toggle_item!(list_id, item_id)

  redirect "/lists/#{list_id}"
end

## Delete an item

post '/lists/:list_id/:item_id/delete' do |list_id, item_id|
  @data.delete_item!(list_id, item_id)

  session[:success] = 'Item was deleted.'
  redirect "/lists/#{list_id}"
end

########

helpers do
  def success?
    session.has_key? :success
  end

  def error?
    session.has_key? :error
  end

  def success_message
    session.delete(:success) || ''
  end

  def error_message
    session.delete(:error) || ''
  end

  def re_order(collection)
    collection.partition { |item| item.done? }.flatten
  end
end

########

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
end

def or_invalid_name(thing, template)
  session[:error] = "Invalid #{thing} name."
  halt erb(template)
end
