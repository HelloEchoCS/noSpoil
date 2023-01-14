require 'bcrypt'
require_relative 'dbconnection'

# Provides public instance methods for searching and creating users
class UserHandler
  def initialize(db)
    @db = db
  end
  # PUBLIC INSTENCE METHODS

  # Find user via username, returns a User object. Returns nil if user is not in the database
  # User object contains a BCrypt::Password object so we could compare it with another password string
  def find_by_username(username)
    result = find_user_by_username(username)
    return if result.ntuples.zero?

    password = result[0]['password']
    User.new(username, password)
  end

  # User object returned here doesn't contain password
  # This method is primarily used to track user's sign-in status.
  def find_by_session_id(session_id)
    result = find_user_by_session_id(session_id)
    return if result.ntuples.zero?

    username = result[0]['username']
    User.new(username)
  end

  def create_new_user(username, password)
    user = User.new(username)
    user.password = password # Generate hashed password
    add_new_user(user.username, user.password)
  end

  # SQL STATEMENTS

  def add_new_user(username, password)
    sql = 'INSERT INTO users (username, password) VALUES ($1, $2);'
    @db.query(sql, username, password)
  end

  def find_user_by_username(username)
    sql = 'SELECT * FROM users WHERE username = $1;'
    @db.query(sql, username)
  end

  def find_user_by_session_id(session_id)
    sql = 'SELECT username FROM users WHERE session_id = $1;'
    @db.query(sql, session_id)
  end

  def update_session_id(username, new_session_id)
    sql = 'UPDATE users SET session_id = $1 WHERE username = $2;'
    @db.query(sql, new_session_id, username)
  end

  def remove_session_id(username)
    sql = 'UPDATE users SET session_id = NULL WHERE username = $1;'
    @db.query(sql, username)
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
