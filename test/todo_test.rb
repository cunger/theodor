require 'minitest/autorun'

require 'list'
require 'item'
require 'errors'

class ToDoListTest < Minitest::Test

  def test_newly_created_list_has_name_and_is_empty
    list = ToDo::List.new 'name'

    assert_empty list.items
    assert_equal 'name', list.name
  end

  def test_trailing_whitespaces_in_name_are_removed
    list = ToDo::List.new '  name    '

    assert_equal 'name', list.name
  end

  def test_name_must_be_provided
    assert_raises ArgumentError do
      ToDo::List.new
    end
  end

  def test_name_must_be_nonempty
    assert_raises ToDo::EmptyNameError do
      ToDo::List.new '  '
    end
  end

  def test_path_from_name
    list = ToDo::List.new '  name  '

    assert_equal 'name', list.path.gsub(/x*$/, '')
  end

  def test_path_from_name_with_non_ascii_characters
    list = ToDo::List.new 'Fußbälle kaufen'

    assert_equal 'Fu_b_lle-kaufen', list.path.gsub(/x*$/, '')
  end

  def test_adding_an_item
    list = ToDo::List.new 'name'
    item = ToDo::Item.new 'do something'
    list << item

    assert_equal 1, list.size
    assert_equal item, list[0]
  end

  def test_done_if_all_items_done
    list  = ToDo::List.new 'name'
    item1 = ToDo::Item.new 'do something'
    item2 = ToDo::Item.new 'do something else'
    list << item1
    list << item2

    refute list.done?
    item1.done!
    refute list.done?
    item2.done!
    assert list.done?
    item1.undone!
    refute list.done?
  end
end

class ToDoItemTest < Minitest::Test

  def test_newly_created_item_has_name_and_is_not_done
    item = ToDo::Item.new 'name'

    assert_equal 'name', item.name
    refute item.done?
  end

  def test_name_must_be_provided
    assert_raises ArgumentError do
      ToDo::Item.new
    end
  end

  def test_name_must_be_nonempty
    assert_raises ToDo::EmptyNameError do
      ToDo::Item.new '  '
    end
  end

  def test_trailing_whitespaces_in_name_are_removed
    item = ToDo::Item.new '  name    '

    assert_equal 'name', item.name
  end

  def test_setting_item_to_done_and_undone
    item = ToDo::Item.new 'name'

    item.done!
    assert item.done?

    item.undone!
    refute item.done?
  end
end
