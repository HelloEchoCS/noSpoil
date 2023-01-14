require 'pg'

# Responsible for establish/close database connection and execute SQL statements
# Collaborator object for ItemHandler, ProductHandler and UserHandler objects
class DatabaseConnection
  def initialize(logger = nil)
    @db = PG.connect(dbname: 'ns_db')
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
end
