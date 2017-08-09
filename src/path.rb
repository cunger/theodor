require_relative 'errors'

class ToDo::Path
  @@paths = []

  def self.exists?(path)
    @@paths.include? path
  end

  def self.from(name)
    path = name.gsub(/\s+|_/, '-').gsub(/[^\w\d\-]/, '_')
    path += 'x' while @@paths.include? path
    @@paths << path
    path
  end
end
