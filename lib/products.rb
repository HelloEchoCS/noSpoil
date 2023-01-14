require_relative 'configuration'

# Responsible for interaction with DatabaseConnection object
# Defines SQL statements for DatabaseConnection object to execute
# Defines interfaces that returns `Products` and `Product` objects for Sinatra and `erb` files
class ProductHandler
  def initialize(db)
    @db = db
  end

  def product_exist?(name)
    find_product_by_name(name)
  end

  def find_product_by_id(id)
    result = find_product_data_by_id(id)
    return nil if result.ntuples.zero?

    Product.new(
      result[0]['id'],
      result[0]['name'],
      result[0]['unit']
    )
  end

  def find_product_by_name(name)
    result = find_product_data_by_name(name)
    return nil if result.ntuples.zero?

    Product.new(
      result[0]['id'],
      result[0]['name'],
      result[0]['unit']
    )
  end

  def all_products
    products = Products.new
    result = retrieve_all_product_data
    result.each do |tuple|
      product = Product.new(tuple['id'], tuple['name'], tuple['unit'])
      products << product
    end
    products
  end

  def all_products_with_stats(page_num)
    products = Products.new
    result = retrieve_all_product_data_with_stats(page_num)
    result.each do |tuple|
      product = Product.new(tuple['id'], tuple['name'], tuple['unit'])
      product.total_item_count = tuple['total_item_count']
      product.in_stock_item_count = tuple['in_stock_item_count']
      product.spoiled_item_count = tuple['spoiled_item_count']
      products << product
    end
    products
  end

  def total_product_count
    result = count_all_product
    result[0]['count'].to_i
  end

  # SQL Statements

  def add_new_product(name, unit)
    sql = 'INSERT INTO products (name, unit) VALUES ($1, $2);'
    @db.query(sql, name, unit)
  end

  def update_product(id, name, unit)
    sql = 'UPDATE products SET name = $1, unit = $2 WHERE id = $3;'
    @db.query(sql, name, unit, id)
  end

  def delete_product(id)
    sql = 'DELETE FROM products WHERE id = $1;'
    @db.query(sql, id)
  end

  # Private instance methods (SQL statements)
  private

  def find_product_data_by_name(name)
    sql = 'SELECT id FROM products WHERE name = $1;'
    @db.query(sql, name)
  end

  def find_product_data_by_id(id)
    sql = 'SELECT * FROM products WHERE id = $1;'
    @db.query(sql, id)
  end

  def retrieve_all_product_data
    sql = 'SELECT * FROM products;'
    @db.query(sql)
  end

  def retrieve_all_product_data_with_stats(page_num)
    items_per_page = Configuration::ITEMS_PER_PAGE
    offset = items_per_page * (page_num - 1)
    sql = <<~SQL
      SELECT products.*,
      (SELECT sum(quantity) FROM items WHERE items.product_id = products.id) AS total_item_count,
      (SELECT sum(quantity) FROM items WHERE status = 'in stock' AND items.product_id = products.id) AS in_stock_item_count,
      (SELECT sum(quantity) FROM items WHERE status = 'spoiled' AND items.product_id = products.id) AS spoiled_item_count
      FROM products
      ORDER BY id DESC
      LIMIT $1 OFFSET $2;
    SQL
    @db.query(sql, items_per_page, offset)
  end

  def count_all_product
    sql = 'SELECT count(id) FROM products;'
    @db.query(sql)
  end


end

# an `Products` object encapsulates a collection of `Product` objects
class Products
  include Enumerable

  def initialize
    @products = []
  end

  def <<(product)
    @products << product
  end

  def each
    @products.each { |product| yield(product) }
  end

  def [](index)
    @products[index]
  end
end

# `Product` class provides interfaces to retrieve attributes and status from a single product
class Product
  attr_reader :id, :name, :unit, :in_stock_item_count, :spoiled_item_count

  def initialize(id, name, unit)
    @id = id
    @name = name
    @unit = unit
  end

  def total_item_count=(count)
    @total_item_count = count.to_i
  end

  def in_stock_item_count=(count)
    @in_stock_item_count = count.to_i
  end

  def spoiled_item_count=(count)
    @spoiled_item_count = count.to_i
  end

  def spoil_rate
    return nil if @total_item_count.zero? # See `format_rate` helper method on how to deal with `nil` here

    @spoiled_item_count / @total_item_count.to_f
  end
end
