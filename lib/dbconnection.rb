require 'pg'
require 'mongo'

# Responsible for establish/close database connection and execute SQL statements
# Collaborator object for ItemHandler, ProductHandler and UserHandler objects
class DatabaseConnection
  def initialize(logger = nil)
    mongo_client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'test')
    @mongo_db = mongo_client[:users]
    @db = PG.connect(dbname: 'ns_db')
    @logger = logger
  end

  def mongo_db
    @mongo_db
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
end
