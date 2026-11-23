require_relative 'shell'
require_relative 'config'
require_relative 'session'

begin
  options = Config.read(ARGV)
  %w[config vfs log script].each { |key| puts "#{key}=#{options[key] || '—'}" }
  Session.new(options).run
rescue ArgumentError, SystemCallError, Psych::Exception, OptionParser::ParseError => e
  warn e.message
  exit 1
end
