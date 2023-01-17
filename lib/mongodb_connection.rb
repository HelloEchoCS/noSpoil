require 'mongo'

class MongoDatabaseConnection
  def initialize()
    @mongo_client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'test')
  end

  def user_collection
    @mongo_client[:users]
  end

  # def disconnect
  #   @db.close
  # end
end