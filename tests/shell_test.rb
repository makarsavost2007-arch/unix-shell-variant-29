require 'minitest/autorun'
require_relative '../src/shell'

class ShellTest < Minitest::Test
  def test_exit
    assert_equal :exit, Shell.new.execute('exit')
    assert_raises(ArgumentError) { Shell.new.execute('exit 1') }
  end

  def test_unknown
    assert_raises(ArgumentError) { Shell.new.execute('unknown') }
  end
end
