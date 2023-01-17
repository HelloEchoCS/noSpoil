require 'bcrypt'
require_relative 'dbconnection'

# Provides public instance methods for searching and creating users
class MongoUserHandler
  def initialize(db)
    @db = db
  end
  # PUBLIC INSTENCE METHODS

  # Find user via username, returns a User object. Returns nil if user is not in the database
  # User object contains a BCrypt::Password object so we could compare it with another password string
  def find_by_username(username)
    result = find_user_by_username(username)
    return if result.nil?

    password = result['password']
    User.new(username, password)
  end

  # User object returned here doesn't contain password
  # This method is primarily used to track user's sign-in status.
  def find_by_session_id(session_id)
    result = find_user_by_session_id(session_id)
    return if result.nil?

    username = result['username']
    User.new(username)
  end

  def create_new_user(username, password)
    user = User.new(username)
    user.password = password # Generate hashed password
    add_new_user(user.username, user.password)
  end

  # MONGO QUERIES

  def add_new_user(username, password)
    doc = { 'username' => username,
            'password' => password
          }

    @db.insert_one(doc)
  end

  def find_user_by_username(username)
    @db.find({ 'username' => username }).first
  end

  def find_user_by_session_id(session_id)
    @db.find({ 'session_id' => session_id }).first
  end

  def update_session_id(username, new_session_id)
    @db.update_one({ 'username' => username }, { 'session_id' => new_session_id })
  end

  def remove_session_id(username)
    @db.update_one({ 'username' => username }, { 'session_id' => '' })
  end
end

# Provides public instances to read user data
class User
  attr_reader :username, :password

  def initialize(username, password = nil)
    @username = username
    # Add guard clause here since BCrypt doesn't handle `nil` as an argument
    @password = BCrypt::Password.new(password) if password
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
  end
end
