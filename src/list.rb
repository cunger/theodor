require_relative 'path'
require_relative 'errors'

class ToDo::List
  attr_accessor :items, :name, :path

  def initialize(name)
    name = name.strip
    raise ToDo::EmptyNameError if name.empty?

    @name  = name
    @path  = ToDo::Path.from name
    @items = []
  end

  def <<(item)
    @items << item
  end

  def [](index)
    @items[index]
  end

  def size
    @items.size
  end

  def number_of_done_items
    @items.select(&:done?).size
  end

  def number_of_remaining_items
    @items.reject(&:done?).size
  end

  def each(&block)
    @items.each do |item|
      block.call item
    end
  end

  def done?
    !@items.empty? && @items.all?(&:done?)
  end

  def done!
    @items.each do |item|
      item.done!
    end
  end

  def toggle(item_id, done?)
    return unless done?
    done? == 'true' ? @items[item_id].done! : @items[item_id].undone!
  end

  def delete_item(item_id)
    @items.delete_at(item_id)
  end
end
