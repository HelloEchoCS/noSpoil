require_relative 'configuration'

# Responsible for interaction with DatabaseConnection object
# Defines SQL statements for DatabaseConnection object to execute
# Defines interfaces that returns `Items` and `Item` objects for Sinatra and `erb` files
class ItemHandler
  def initialize(db)
    @db = db
  end

  # Public instance methods

  def find_item_by_id(item_id)
    result = retrieve_single_item_data_by_id(item_id)
    return nil if result.ntuples.zero?

    Item.new(
      result[0]['id'],
      result[0]['product'],
      result[0]['quantity'],
      result[0]['best_before']
    )
  end

  def all_items_by_product_id(product_id, page_num)
    items = Items.new
    result = retrieve_all_items_data_by_product_id_by_page(product_id, page_num)
    result.each do |tuple|
      item = Item.new(
        tuple['id'],
        tuple['product'],
        tuple['quantity'],
        tuple['best_before'],
        tuple['unit'],
        tuple['status']
      )
      items << item
    end
    items
  end

  def all_items_in_stock(page_num)
    items = Items.new
    result = retrieve_in_stock_items_data_by_page(page_num)
    result.each do |tuple|
      item = Item.new(
        tuple['id'],
        tuple['product'],
        tuple['quantity'],
        tuple['best_before'],
        tuple['unit']
      )
      items << item
    end
    items
  end

  def consume(item_id)
    update_status_as_consumed(item_id)
  end

  def spoil(item_id)
    update_status_as_spoiled(item_id)
  end

  def count_all(product_id)
    result = count_all_items_by_product_id(product_id)
    result[0]['count'].to_i
  end

  def count_in_stock
    result = count_in_stock_items
    result[0]['count'].to_i
  end

  def count_due_today
    result = count_due_today_items
    result[0]['count'].to_i
  end

  def count_due_imminent
    result = count_due_imminent_items(Configuration::DUE_IMMINENT_DAYS)
    result[0]['count'].to_i
  end

  # SQL statements

  def update_item(item_id, product_id, quantity, best_before)
    sql = 'UPDATE items SET product_id = $2, quantity = $3, best_before = $4 WHERE id = $1;'
    @db.query(sql, item_id, product_id, quantity, best_before)
  end

  def delete_item(item_id)
    sql = 'DELETE FROM items WHERE id = $1;'
    @db.query(sql, item_id)
  end

  def add_new_item(product_id, quantity, best_before)
    sql = 'INSERT INTO items (product_id, quantity, best_before) VALUES ($1, $2, $3);'
    @db.query(sql, product_id, quantity, best_before)
  end

  # Private instance methods (SQL statements)
  private

  def retrieve_in_stock_items_data_by_page(page_num)
    items_per_page = Configuration::ITEMS_PER_PAGE
    offset = items_per_page * (page_num - 1)
    sql = <<~SQL
      SELECT items.id, products.name AS product, items.quantity, products.unit AS unit, best_before FROM items
      INNER JOIN products ON items.product_id = products.id
      WHERE status = 'in stock'
      ORDER BY best_before, items.id
      LIMIT $1 OFFSET $2;
    SQL
    @db.query(sql, items_per_page, offset)
  end

  def retrieve_all_items_data_by_product_id_by_page(product_id, page_num)
    items_per_page = Configuration::ITEMS_PER_PAGE
    offset = items_per_page * (page_num - 1)
    sql = <<~SQL
      SELECT items.id, products.name AS product, items.status AS status, items.quantity, products.unit AS unit, best_before FROM items
      INNER JOIN products ON items.product_id = products.id
      WHERE items.product_id = $1
      ORDER BY best_before DESC, items.id
      LIMIT $2 OFFSET $3;
    SQL
    @db.query(sql, product_id, items_per_page, offset)
  end

  def retrieve_single_item_data_by_id(item_id)
    sql = <<~SQL
      SELECT items.id, products.name AS product, items.quantity, best_before FROM items
      INNER JOIN products ON items.product_id = products.id
      WHERE items.id = $1
      LIMIT 1;
    SQL
    @db.query(sql, item_id)
  end

  def update_status_as_consumed(item_id)
    sql = "UPDATE items SET status = 'consumed' WHERE id = $1;"
    @db.query(sql, item_id)
  end

  def update_status_as_spoiled(item_id)
    sql = "UPDATE items SET status = 'spoiled' WHERE id = $1;"
    @db.query(sql, item_id)
  end

  def count_all_items_by_product_id(product_id)
    sql = 'SELECT count(id) FROM items WHERE product_id = $1;'
    @db.query(sql, product_id)
  end

  def count_in_stock_items
    sql = "SELECT count(id) FROM items WHERE status = 'in stock';"
    @db.query(sql)
  end

  def count_due_today_items
    sql = "SELECT count(id) FROM items WHERE best_before = current_date AND status = 'in stock';"
    @db.query(sql)
  end

  def count_due_imminent_items(imminent_criteria)
    sql = "SELECT count(id) FROM items WHERE (best_before - current_date) BETWEEN 1 AND $1 AND status = 'in stock';"
    @db.query(sql, imminent_criteria)
  end
end

# an `Items` object encapsulates a collection of `Item` objects
class Items
  include Enumerable

  def initialize
    @items = []
  end

  def <<(item)
    @items << item
  end

  def each
    @items.each { |item| yield(item) }
  end

  def [](index)
    @items[index]
  end
end

# `Item` class provides interfaces to retrieve attributes and status from a single item
class Item
  attr_reader :id, :product, :quantity, :bbd, :unit, :status

  def initialize(id, product, quantity, bbd, unit = nil, status = nil)
    @id = id
    @product = product
    @quantity = quantity
    @bbd = bbd
    @unit = unit
    @status = status
  end

  def in_stock?
    @status == 'in stock'
  end

  def consumed?
    @status == 'consumed'
  end

  def spoiled?
    @status == 'spoiled'
  end

  def days_left
    (Date.parse(@bbd) - Date.today).to_i
  end

  def expired?
    days_left.negative?
  end

  def due_today?
    days_left.zero?
  end

  def due_imminent?
    days_left.positive? && days_left <= 5
  end
end
