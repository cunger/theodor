module ToDo
  class Item
    attr_reader :id, :name

    def initialize(id, name, done=false)
      @id   = id
      @name = name
      @done = done
    end

    def done?
      @done
    end

    def toggle!
      @done = !@done
    end
  end
end
