require "test/unit"
require File.expand_path("../../lib/on_event", __FILE__)

class TestOnEvent < Test::Unit::TestCase
  def test_setup_with_no_block
    subject = OnEvent.new(:foo, :bar)
    assert subject.respond_to?(:on_foo)
    assert subject.respond_to?(:foo)
    assert subject.respond_to?(:on_bar)
    assert subject.respond_to?(:bar)
  end

  def test_adding_event_callbacks
    subject = OnEvent.new(:foo, :bar)
    subject.on_foo { |a| a << "f1" }
    subject.on_bar { |a| a << "b1" }
    subject.on_foo { |a| a << "f2" }
    subject.on_bar { |a| a << "b2" }
    a = []
    subject.foo(a)
    subject.bar(a)
    assert_equal %w[f1 f2 b1 b2], a
  end

  def test_adding_establish_event_alias
    subject = OnEvent.new
    subject.establish_event(:foo)
    assert subject.respond_to?(:on_foo)
    assert subject.respond_to?(:foo)
  end

  def test_setup_with_block
    subject = OnEvent.new(:foo, :bar) do |oe|
      oe.on_foo { |a| a << "foo" }
      oe.on_bar { |a| a << "bar" }
    end
    a = []
    subject.foo(a)
    subject.bar(a)
    assert_equal %w[foo bar], a
  end

  def test_rescue_handler
    subject = OnEvent.new(:foo, :bar) do |oe|
      oe.on_foo { |a| a << "foo" }
      oe.on_bar { |a| a << oops_missing }
      oe.on_bar { |a| a << oops_another }
    end

    $handledExceptions = []
    def subject.rescue_handler(exception)
      $handledExceptions << exception.message
    end

    a = []
    subject.foo(a)
    subject.bar(a)
    assert_equal ["foo"], a
    assert_match /oops_missing/, $handledExceptions[0]
    assert_match /oops_another/, $handledExceptions[1]
  end

  def test_logger
    subject = OnEvent.new
    assert_kind_of Logger, subject.logger
  end
end
