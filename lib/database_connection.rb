require 'pg'

require_relative 'todo_list'
require_relative 'todo_item'

module ToDo
  class DatabaseConnection
    def initialize(dbname, logger)
      @db = PG.connect(dbname: dbname)
      @logger = logger
    end

    def exec_sql(statement, *params)
      log(statement, params)
      @db.exec_params(statement, params)
    end

    def lists
      results = exec_sql("SELECT * FROM todo_lists;")
      results.map do |result|
        populate ToDo::List.new(Integer(result['id']), result['name'])
      end
    end

    def add_list!(list_name)
      if valid?(list_name)
        exec_sql("INSERT INTO todo_lists (name) VALUES ($1);", @db.escape_string(list_name))
      else
        yield if block_given?
      end
    end

    def find_list(list_id)
      results = exec_sql("SELECT * FROM todo_lists WHERE id = $1;", list_id)
      results.each do |result|
        return populate ToDo::List.new(Integer(result['id']), result['name'])
      end
      yield if block_given?
    end

    def find_list_name(list_id)
      results = exec_sql("SELECT name FROM todo_lists WHERE id = $1;", list_id)
      results.each do |result|
        return result['name']
      end
      yield if block_given?
    end

    def rename_list!(list_id, new_name)
      if valid?(new_name)
        update = "UPDATE todo_lists SET name = $1 WHERE id = $2;"
        exec_sql(update, @db.escape_string(new_name), list_id)
      else
        yield if block_given?
      end
    end

    def mark_list_as_done!(list_id)
      sql = "UPDATE todo_items SET done = true WHERE todo_list_id = $1;"
      exec_sql(sql, list_id)
    end

    def add_item!(list_id, item_name)
      if valid?(item_name)
        update = "INSERT INTO todo_items (name, todo_list_id) VALUES ($1, $2);"
        exec_sql(update, @db.escape_string(item_name), list_id)
      else
        yield if block_given?
      end
    end

    def delete_item!(list_id, item_id)
      update = "DELETE FROM todo_items WHERE id = $1 AND todo_list_id = $2;"
      exec_sql(update, item_id, list_id)
    end

    def delete_list!(list_id)
      update = "DELETE FROM todo_lists WHERE id = $1;"
      exec_sql(update, list_id)
    end

    def toggle_item!(list_id, item_id)
      query      = "SELECT done FROM todo_items WHERE id = $1 AND todo_list_id = $2;"
      results    = exec_sql(query, item_id, list_id)
      status     = results[0]['done']
      new_status = !Boolean(status)
      update     = "UPDATE todo_items SET done = $1 WHERE id = $2 AND todo_list_id = $3;"
      exec_sql(update, new_status, item_id, list_id)
    end

    private

    def log(statement, params)
      log = statement
      unless params.empty?
        log += " with "
        log += params.map.with_index { |p, i| "$#{i+1} = #{p}" }.join(', ')
      end
      @logger.info log
    end

    def populate(list)
      query = "SELECT * FROM todo_items WHERE todo_list_id = $1;"
      items = exec_sql(query, list.id)
      items.each do |item|
        list << ToDo::Item.new(Integer(item['id']), item['name'], Boolean(item['done']))
      end
      list
    end

    def valid?(name)
      !name.strip.empty?
    end

    def Boolean(string)
      ['true', 't', '1'].include? string.downcase
    end
  end
end
