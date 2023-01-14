require 'sinatra'

require_relative 'configuration'

# Route Helpers

def authenticate(username, password)
  @user = @user_handler.find_by_username(username)
  if user_valid?(@user, password)
    @user_handler.update_session_id(username, session.id)
    session[:success] = 'Successfully signed in.'
    redirect session[:destination] if session[:destination]
    redirect '/'
  else
    session[:error] = 'Cannot sign in. Please check your username and password.'
    status 422
  end
end

def sign_up(username, password)
  @user = @user_handler.find_by_username(username)
  if @user.nil?
    @user_handler.create_new_user(username, password)
    @user_handler.update_session_id(username, session.id)
    session[:success] = 'Successfully signed in.'
    redirect '/'
  else
    session[:error] = "Username '#{username}' has already been taken, please choose a different one."
    status 422
  end
end

def require_user_signed_in
  unless already_signed_in?
    session[:destination] = request.path
    session[:error] = 'You must be signed in to do that.'
    redirect '/sign_in'
  end

  session.delete(:destination)
end

def already_signed_in?
  @user
end

def user_valid?(user, password)
  user && user.password == password
end

def handle_invalid_product(name, id = nil)
  product = @product_handler.find_product_by_name(name)
  if name.strip.length.zero?
    session[:error] = "Product name cannot be spaces only."
  elsif !product.nil? && id != product.id
    session[:error] = "Product '#{name}' already exists, please choose another one."
  end
end

def handle_invalid_unit(unit)
  session[:error] = "Unit cannot be spaces only." if unit.strip.length.zero?
end

def add_new_product(name, unit)
  @product_handler.add_new_product(name, unit)
  session[:success] = 'Product created successfully.'
  redirect '/product'
end

def edit_product(id, name, unit)
  @product_handler.update_product(id, name, unit)
  session[:success] = 'Product updated successfully.'
  redirect '/product'
end

def validate_page_number
  return if integer?(@page) && (@page.to_i <= @page_count)

  session[:error] = 'The page number you requested does not exist.'
  redirect request.path
end

def handle_non_existent_item(item_id)
  @item = integer?(item_id) ? @item_handler.find_item_by_id(item_id) : nil
  return unless @item.nil?

  session[:error] = "The item '#{item_id}' that you requested does not exist."
  redirect '/stock'
end

def handle_non_existent_product(product_id)
  @product = integer?(product_id) ? @product_handler.find_product_by_id(product_id) : nil
  return unless @product.nil?

  session[:error] = "The product '#{product_id}' you requested does not exist."
  redirect '/product'
end

def calculate_pages(count)
  items_per_page = Configuration::ITEMS_PER_PAGE
  pages = count / items_per_page
  pages = (count % items_per_page).positive? ? pages + 1 : pages
  pages.zero? ? 1 : pages
end

def integer?(id)
  id.is_a?(Integer) || id.to_i.to_s == id
end