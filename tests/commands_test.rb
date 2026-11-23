require 'minitest/autorun'
require_relative '../src/shell'

class CommandsTest < Minitest::Test
  IMAGE = File.expand_path('../examples/deep.xml', __dir__)

  def setup
    @shell = Shell.new(Vfs.new(IMAGE))
  end

  def test_navigation
    @shell.execute('cd course/week')
    assert_output("/course/week\n") { @shell.execute('pwd') }
    assert_output("6\t/course/week\n") { @shell.execute('du') }
    @shell.execute('cd ..')
    assert_output("week\n") { @shell.execute('ls') }
    assert_raises(ArgumentError) { @shell.execute('cd /notes.txt') }
  end

  def test_move_and_delete
    original = File.binread(IMAGE)
    @shell.execute('cd course')
    @shell.execute('mv /course /term')
    assert_output("/term\n") { @shell.execute('pwd') }
    @shell.execute('mv /notes.txt .')
    assert_raises(ArgumentError) { @shell.execute('mv /term week') }
    assert_raises(ArgumentError) { @shell.execute('rm -r .') }
    @shell.execute('rm notes.txt')
    @shell.execute('cd')
    @shell.execute('rm -r term')
    assert_output("0\t/\n") { @shell.execute('du') }
    assert_equal original, File.binread(IMAGE)
    assert_equal %w[course notes.txt], Vfs.new(IMAGE).root.keys.sort
  end
end
