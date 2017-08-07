require_relative 'list'
require_relative 'item'

module ToDo
  module Example
    def self.get_your_shit_together
      ToDo::List.new 'Get your shit together'
    end

    def self.build_a_rocket
      list = ToDo::List.new 'Build a rocket'

      list << ToDo::Item.new('Download a blueprint from ESA')
      list << ToDo::Item.new('Assemble')

      list
    end
  end
end
