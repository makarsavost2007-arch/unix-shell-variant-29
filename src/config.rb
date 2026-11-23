require 'yaml'
require 'optparse'

class Config
  KEYS = %w[vfs log script].freeze

  def self.read(argv)
    cli = {}
    parser = OptionParser.new do |opts|
      (KEYS + ['config']).each do |key|
        opts.on("--#{key} PATH") { |value| cli[key] = value }
      end
    end
    parser.parse!(argv)
    raise ArgumentError, "Лишние аргументы: #{argv.join(' ')}" unless argv.empty?
    path = cli['config']
    settings = path ? YAML.safe_load(File.read(path)) : {}
    unless settings.is_a?(Hash) && (settings.keys - KEYS).empty?
      raise ArgumentError, 'Ожидается YAML-словарь с ключами vfs, log, script'
    end
    settings.each do |key, value|
      raise ArgumentError, "Некорректный путь #{key}" unless value.is_a?(String) && !value.empty?
      settings[key] = File.expand_path(value, File.dirname(path))
    end
    settings.merge(cli)
  end
end
