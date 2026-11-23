require 'etc'
require 'socket'

class Shell
  attr_reader :user

  def initialize
    @user = Etc.getpwuid.name
    @host = Socket.gethostname
    @cwd = '/'
  end

  def prompt
    "#{@user}@#{@host}:#{@cwd}$ "
  end

  def execute(line)
    name, *args = line.split
    return unless name
    case name
    when 'exit'
      raise ArgumentError, 'exit без аргументов' unless args.empty?
      :exit
    when 'ls', 'cd'
      puts ([name] + args).join(' ')
    else
      raise ArgumentError, "Неизвестная команда: #{name}"
    end
  end

  def interact
    loop do
      print prompt
      $stdout.flush
      line = $stdin.gets
      break unless line
      begin
        break if execute(line) == :exit
      rescue ArgumentError => e
        warn e.message
      end
    end
  end
end
