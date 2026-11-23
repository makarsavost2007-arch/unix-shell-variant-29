require_relative 'vfs'
require 'csv'
require 'time'

class Session < Shell
  def initialize(options)
    super(Vfs.new(options['vfs']))
    @options = options
  end

  def execute(line)
    record(line.strip) unless line.strip.empty?
    super
  end

  def record(command)
    return unless @options['log']
    File.open(@options['log'], 'ab') do |file|
      file.flock(File::LOCK_EX)
      file.write(CSV.generate_line(%w[username timestamp command])) if file.size.zero?
      file.write(CSV.generate_line([user, Time.now.iso8601, command]))
    end
  end

  def run
    if @options['script']
      File.foreach(@options['script']).with_index(1) do |line, n|
        puts "#{prompt}#{line.chomp}"
        begin
          return if execute(line) == :exit
        rescue ArgumentError => e
          raise ArgumentError, "#{@options['script']}:#{n}: #{e.message}"
        end
      end
    end
    interact
  end
end
