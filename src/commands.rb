module Commands
  def absolute(path)
    parts = path.start_with?('/') ? [] : @cwd.split('/').reject(&:empty?)
    path.split('/').each do |part|
      next if part.empty? || part == '.'
      part == '..' ? parts.pop : parts << part
    end
    '/' + parts.join('/')
  end

  def lookup(path)
    path.split('/').reject(&:empty?).reduce(@vfs.root) do |dir, part|
      raise ArgumentError, "Нет каталога в пути #{path}" unless dir.is_a?(Hash)
      dir.fetch(part) { raise ArgumentError, "Путь не найден: #{path}" }
    end
  end

  def display_tree(node, prefix = '')
    return unless node.is_a?(Hash)
    names = node.keys.sort
    names.each do |name|
      last = name == names.last
      puts prefix + (last ? '└── ' : '├── ') + name
      display_tree(node[name], prefix + (last ? '    ' : '│   '))
    end
  end

  def bytes(node)
    node.is_a?(Hash) ? node.values.sum { |child| bytes(child) } : node.bytesize
  end

  def navigate(name, args)
    raise ArgumentError, "#{name}: лишние аргументы" if args.size > 1
    path = absolute(args.first || (name == 'cd' ? '/' : '.'))
    node = lookup(path)
    case name
    when 'ls' then puts(node.is_a?(Hash) ? node.keys.sort : File.basename(path))
    when 'tree'
      puts path
      display_tree(node)
    when 'du' then puts "#{bytes(node)}\t#{path}"
    when 'cd'
      raise ArgumentError, "Это файл: #{path}" unless node.is_a?(Hash)
      @cwd = path
    end
  end
end
