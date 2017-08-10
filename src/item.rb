require_relative 'errors'

class ToDo::Item
  attr_reader :name

  def initialize(name)
    name = name.strip
    raise ToDo::EmptyNameError if name.empty?

    @name = name
    @done = false
  end

  def done!
    @done = true
  end

  def undone!
    @done = false
  end

  def done?
    @done
  end
  
  def view
    # TODO
  end
end
