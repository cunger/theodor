require_relative 'path'
require_relative 'errors'

class ToDo::List
  attr_reader :items, :name, :path

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

  def each(&block)
    @items.each do |item|
      block.call item
    end
  end

  def done?
    @items.all? { |item| item.done? }
  end

  def view
    # TODO
  end
end
