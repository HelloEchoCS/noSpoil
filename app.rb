require 'dotenv/load'
require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

require_relative 'lib/dbconnection'
require_relative 'lib/mongodb_connection'
require_relative 'lib/user_mongo'
require_relative 'lib/user'
require_relative 'lib/items'
require_relative 'lib/products'
require_relative 'lib/route_helpers'
require_relative 'lib/view_helpers'

EXCLUDED_PATH = ['/sign_in', '/sign_up'].freeze # paths that don't need user to be signed-in

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'lib/*.rb'
end

before do
  @db = DatabaseConnection.new(logger)
  @mongo_db = MongoDatabaseConnection.new()
  @user_collection = @mongo_db.user_collection
  @user_handler = MongoUserHandler.new(@user_collection)
  @item_handler = ItemHandler.new(@db)
  @product_handler = ProductHandler.new(@db)
  @user = @user_handler.find_by_session_id(session.id) # user is not signed in if @user is nil
  require_user_signed_in unless EXCLUDED_PATH.include?(request.path)
end

after do
  session[:current_items_page] = params['page'] || 1 if request.path == '/stock'
  session[:current_product_page] = params['page'] || 1 if request.path == '/product'
  @db.disconnect
end

helpers ViewHelpers

# 404 page
not_found do
  status 404
  erb :page_not_found
end

# Homepage
get '/' do
  redirect '/stock'
end

# Stock page
get '/stock' do
  @page = params['page'] || 1
  @page_count = calculate_pages(@item_handler.count_in_stock)
  validate_page_number
  @page = @page.to_i # Make `page` available in erb, helping render pagination component correctly
  @items = @item_handler.all_items_in_stock(@page)
  erb :stock
end

# Add a stock item
get '/stock/add' do
  @products = @product_handler.all_products
  erb :'forms/add_item'
end

post '/stock/add' do
  binding.pry
  @item_handler.add_new_item(params['product-id'], params['quantity'], params['best-before-date'])
  session[:success] = 'New item added.'
  redirect '/stock'
end

# Delete a stock item
post '/stock/item/:item_id/delete' do
  @item_handler.delete_item(params['item_id'])
  session[:success] = 'Item deleted.'
  redirect session[:current_page] # Keep user at the same page after deletion
  redirent "/stock?page=#{session[:current_items_page]}"
end

# Edit a stock item
get '/stock/item/:item_id/edit' do
  handle_non_existent_item(params['item_id'])
  @products = @product_handler.all_products
  erb :'forms/edit_item'
end

# Save a stock item
post '/stock/item/:item_id/save' do
  @item_handler.update_item(params['item_id'], params['product-id'], params['quantity'], params['best-before-date'])
  session[:success] = 'Item updated.'
  redirect '/stock'
end

# Consume a stock item
post '/stock/item/:item_id/consume' do
  @item_handler.consume(params['item_id'])
  session[:success] = 'Item consumed.'
  redirect "/stock?page=#{session[:current_items_page]}" # Keep user at the same page after consumption
end

# Spoil a stock item
post '/stock/item/:item_id/spoil' do
  @item_handler.spoil(params['item_id'])
  session[:success] = 'Item spoiled.'
  redirect "/stock?page=#{session[:current_items_page]}" # Keep user at the same page after spoil
end

# Product page
get '/product' do
  @page = params['page'] || 1
  @page_count = calculate_pages(@product_handler.total_product_count)
  validate_page_number
  @page = @page.to_i
  @products = @product_handler.all_products_with_stats(@page)
  erb :product
end

# Add new product
get '/product/add' do
  erb :'forms/add_product'
end

post '/product/add' do
  name = params['product_name']
  unit = params['unit']
  handle_invalid_unit(unit)
  handle_invalid_product(name)
  add_new_product(name, unit) unless session[:error]
  erb :'forms/add_product'
end

# Edit a product
get '/product/:product_id/edit' do
  handle_non_existent_product(params['product_id'])
  erb :'forms/edit_product'
end

post '/product/:product_id/edit' do
  id = params['product_id']
  name = params['product_name']
  unit = params['unit']
  handle_invalid_unit(unit)
  handle_invalid_product(name, id)
  edit_product(id, name, unit) unless session[:error]
  erb :'forms/edit_product'
end

# Delete a product
post '/product/:product_id/delete' do
  @product_handler.delete_product(params['product_id'])
  session[:success] = 'Product deleted.'
  redirect "/product?page=#{session[:current_product_page]}" # Keep user at the same item page after deletion
end

# View product details
get '/product/:product_id' do
  id = params['product_id']
  handle_non_existent_product(id)
  @page = params['page'] || 1
  @page_count = calculate_pages(@item_handler.count_all(id))
  validate_page_number
  @page = @page.to_i
  @items = @item_handler.all_items_by_product_id(id, @page)
  @products = @product_handler.all_products
  erb :product_details
end

# Add a stock item from product details page
get '/product/:product_id/add' do
  handle_non_existent_product(params['product_id'])
  erb :'forms/add_item_for_product'
end

post '/product/:product_id/add' do
  @item_handler.add_new_item(params['product_id'], params['quantity'], params['best-before-date'])
  session[:success] = 'New item added.'
  redirect "/product/#{params['product_id']}"
end

# Delete a stock item from product details page
post '/product/:product_id/item/:item_id/delete' do
  @item_handler.delete_item(params['item_id'])
  session[:success] = 'Item deleted.'
  redirect "/product/#{params['product_id']}"
end

# Save a stock item from product details page
post '/product/:product_id/item/:item_id/save' do
  @item_handler.update_item(params['item_id'], params['selected_product_id'], params['quantity'], params['best-before-date'])
  session[:success] = 'Item updated.'
  redirect "/product/#{params['product_id']}"
end

# Consume a stock item from product details page
post '/product/:product_id/item/:item_id/consume' do
  @item_handler.consume(params['item_id'])
  session[:success] = 'Item consumed.'
  redirect "/product/#{params['product_id']}"
end

# Spoil a stock item from product details page
post '/product/:product_id/item/:item_id/spoil' do
  @item_handler.spoil(params['item_id'])
  session[:success] = 'Item spoiled.'
  redirect "/product/#{params['product_id']}"
end

# Sign in
get '/sign_in' do
  redirect '/' if already_signed_in?

  erb :sign_in, layout: :auth_layout
end

# User press the 'Sign In' button
post '/sign_in' do
  username = params['username']
  password = params['password']
  authenticate(username, password)
  erb :sign_in, layout: :auth_layout
end

# Sign up
get '/sign_up' do
  redirect '/' if already_signed_in?

  erb :sign_up, layout: :auth_layout
end

post '/sign_up' do
  username = params['username']
  password = params['password']
  sign_up(username, password)

  erb :sign_up, layout: :auth_layout
end

# Sign out
post '/sign_out' do
  @user_handler.remove_session_id(@user.username)
  session.clear
  session[:success] = 'You have been signed out.'

  redirect '/sign_in'
end
