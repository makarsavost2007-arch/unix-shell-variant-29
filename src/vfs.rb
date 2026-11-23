require 'rexml/document'
require 'base64'

class Vfs
  attr_reader :root

  def initialize(path = nil)
    @root = {}
    return unless path
    doc = REXML::Document.new(File.read(path))
    raise ArgumentError, 'DTD запрещён' if doc.doctype
    raise ArgumentError, 'Ожидается корень <vfs>' unless doc.root&.name == 'vfs'
    @root = directory(doc.root)
  rescue REXML::ParseException => e
    raise ArgumentError, "Некорректный XML: #{e.message}"
  end

  def directory(element)
    entries = {}
    element.elements.each do |child|
      name = child.attributes['name']
      if name.to_s.empty? || %w[. ..].include?(name) || name.match?(%r{[/\s]}) || entries.key?(name)
        raise ArgumentError, "Некорректное или повторное имя: #{name.inspect}"
      end
      entries[name] = case child.name
                      when 'dir' then directory(child)
                      when 'file' then file_data(child)
                      else raise ArgumentError, "Неизвестный узел #{child.name}"
                      end
    end
    entries
  end

  def file_data(element)
    raise ArgumentError, 'Вложенный узел в файле' if element.has_elements?
    Base64.strict_decode64(element.text.to_s.gsub(/\s/, ''))
  end
end
