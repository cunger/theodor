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

    def count_all_items
      @items.size
    end

    def count_done_items
      @items.count { |item| item.done? }
    end

    def count_todo_items
      count_all_items - count_done_items
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

  class HollowList
    attr_accessor :id, :name, :count_all_items, :count_done_items

    def initialize(id, name, count_all_items=0, count_done_items=0)
      @id    = id
      @name  = name
      @count_all_items  = count_all_items
      @count_done_items = count_done_items
    end

    def done?
      count_all_items > 0 && (count_all_items - count_done_items == 0)
    end
  end
end
