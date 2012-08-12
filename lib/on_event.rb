require "on_event/version"
require 'logger'

class OnEvent
  def initialize(*events)
    establish_events(*events)
    yield self if block_given?
  end

  ##
  # This defines an #event_name and #on_event_name method for
  # each given event. #on_event_name takes a block stored
  # as a callback, which is passed the args from corresponding
  # calls to #event_name
  #
  #   # Regular Style:
  #   on_event = OnEvent.new(:success, :failure)
  #   on_event.on_success { |a| a << "A success" }
  #   on_event.on_failure { |a| a << "A failure" }
  #
  #   # Block Style:
  #   on_event = OnEvent.new(:foo, :bar) do |oe|
  #     oe.on_foo { |a| a << "foo" }
  #     oe.on_bar { |a| a << "bar" }
  #   end
  #
  #   a = []
  #   on_event.foo(a)
  #   a # => ["foo",]
  #   on_event.bar(a)
  #   a # => ["foo", "bar"]
  #
  def establish_events(*events)
    (class << self; self; end).instance_eval do
      Array(events).each do |event_name|
        define_method "on_#{event_name}" do |&block|
          event_blocks[event_name.to_sym] << block
        end

        define_method event_name do |*args|
          event_blocks[event_name.to_sym].each do |block|
            with_rescue { block.call *args }
          end
          true
        end
      end
    end
  end
  alias :establish_event :establish_events

  def logger
    @logger ||= Logger.new(STDERR)
  end

  private

  def event_blocks
    @event_blocks ||= Hash.new {|h, k| h[k] = []}
  end

  def with_rescue
    begin
      yield
    rescue => e
      rescue_handler(e)
    end
  end

  def rescue_handler(exception)
    logger.error exception.message
  end
end
