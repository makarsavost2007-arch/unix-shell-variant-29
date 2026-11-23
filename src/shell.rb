require 'etc'
require 'socket'

require_relative 'commands'
require_relative 'vfs'

class Shell
  include Commands
  attr_reader :user

  def initialize(vfs = Vfs.new)
    @vfs = vfs
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
    when 'ls', 'cd', 'tree', 'du'
      navigate(name, args)
    when 'pwd'
      raise ArgumentError, 'pwd без аргументов' unless args.empty?
      puts @cwd
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
