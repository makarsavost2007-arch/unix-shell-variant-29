module Mutations
  def protected_path?(path)
    path == '/' || @cwd == path || @cwd.start_with?(path + '/')
  end

  def remove(args)
    recursive = args.first == '-r'
    args.shift if recursive
    raise ArgumentError, 'Использование: rm [-r] путь' unless args.size == 1
    path = absolute(args.first)
    node = lookup(path)
    raise ArgumentError, 'Каталог занят' if protected_path?(path)
    raise ArgumentError, 'Для каталога нужен rm -r' if node.is_a?(Hash) && !recursive
    lookup(File.dirname(path)).delete(File.basename(path))
  end

  def move(args)
    raise ArgumentError, 'Использование: mv источник назначение' unless args.size == 2
    src, dst = args.map { |arg| absolute(arg) }
    raise ArgumentError, 'Корень нельзя переместить' if src == '/'
    node = lookup(src)
    return if src == dst
    parent = lookup(File.dirname(dst))
    raise ArgumentError, 'Назначение не каталог' unless parent.is_a?(Hash)
    if dst == '/' || parent[File.basename(dst)].is_a?(Hash)
      parent = lookup(dst)
      dst = File.join(dst, File.basename(src))
    end
    return if src == dst
    raise ArgumentError, 'Перемещение внутрь себя' if dst.start_with?(src + '/')
    name = File.basename(dst)
    raise ArgumentError, "Имя занято: #{dst}" if parent.key?(name)
    parent[name] = node
    lookup(File.dirname(src)).delete(File.basename(src))
    @cwd = dst + @cwd.delete_prefix(src) if protected_path?(src)
  end
end
