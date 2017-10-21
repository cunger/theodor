class SessionPersistence

  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def lists
    @session[:lists]
  end

  def find_list(id)
    lists.select { |list| list.path == id }.fetch(0) do
      yield if block_given?
    end
  end

  def add_list(list_name)
    list_name = normalize list_name
    if valid?(list_name, lists)
      lists << ToDo::List.new(list_name)
    else
      yield if block_given?
    end
  end

  def rename_list(list, new_list_name)
    new_list_name = normalize new_list_name
    if valid?(new_list_name, lists)
      list.name = new_list_name
    else
      yield if block_given?
    end
  end

  def add_item(list, item_name)
     item_name = normalize item_name
     if valid?(item_name, list.items)
       list << ToDo::Item.new(item_name)
     else
       yield if block_given?
     end
  end

  def toggle_item(list_id, item_id, status)
    list = find_list(list_id) { yield if block_given? }
    list.toggle(Integer(item_id), status)
  end

  def delete_item(list_id, item_id)
    list = find_list(id) { yield if block_given? }
    list.delete_item(Integer(item_id))
  end

  def delete_list(list_id)
    list = find_list(id) { yield if block_given? }
    lists.delete(list)
  end

  private

  def normalize(string)
    truncate string.strip
  end

  def truncate(string, length=100)
    string.size > length ? string.slice(0, length - 3) + '...' : string
  end

  def valid?(name)
    !name.empty? && unique?(name, collection)
  end

  def unique?(name, collection)
    collection.none? { |element| element.name == name }
  end
end
