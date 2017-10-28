module ToDo
  class List
    attr_accessor :id, :name, :items

    def initialize(id, name, items=[])
      @id    = id
      @name  = name
      @items = items
    end

    def <<(item)
      @items << item
    end

    def done?
      !@items.empty? && @items.all?(&:done?)
    end

    def done!
      @items.each do |item|
        item.done!
      end
    end

    def empty?
      @items.empty?
    end

    def size
      @items.size
    end

    def number_of_done_items
      @items.count { |item| item.done? }
    end

    def number_of_remaining_items
      @items.count { |item| !item.done? }
    end

    def each(&block)
      @items.each do |item|
        block.call item
      end
    end

    def toggle!(item_id)
      item = @items.fetch(item_id)
      item.toggle! if item
    end
  end
end
