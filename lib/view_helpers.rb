require_relative 'configuration'

module ViewHelpers
  def format_days_left(item)
    return 'Due today' if item.due_today?
    return 'Expired' if item.expired?
    return "Expire in #{item.days_left} day(s)" if item.due_imminent?
  end

  def due_status_color(item)
    return 'text-bg-danger' if item.due_today?
    return 'text-bg-warning' if item.due_imminent?
    return 'text-bg-secondary' if item.expired?
  end

  def item_status_color(item)
    return 'text-bg-primary' if item.in_stock?
    return 'text-bg-secondary' if item.spoiled?
    return 'text-bg-success' if item.consumed?
  end

  # Pre-fill product selection when editing an item
  def pre_fill_product_name?(item, product)
    item.product == product.name if item
  end

  def due_today_alert
    count = @item_handler.count_due_today
    return nil if count.zero?

    count
  end

  def due_imminent_alert
    count = @item_handler.count_due_imminent
    return nil if count.zero?

    count
  end

  def format_rate(rate)
    return 'N/A' if rate.nil?

    "#{(rate * 100).round(1)}%"
  end
end
