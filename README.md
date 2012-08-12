# OnEvent

Build callback chains for named events.

## Installation

Add this line to your application's Gemfile:

    gem 'on_event'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install on_event

## Usage

```ruby
# Regular Style:
on_event = OnEvent.new(:success, :failure)
on_event.on_success { |a| a << "A success" }
on_event.on_failure { |a| a << "A failure" }

# Block Style:
on_event = OnEvent.new(:foo, :bar) do |oe|
 oe.on_foo { |a| a << "foo" }
 oe.on_bar { |a| a << "bar" }
end

a = []
on_event.foo(a)
a # => ["foo",]
on_event.bar(a)
a # => ["foo", "bar"]
```

## Why is this useful?

You could just put event calls inline in a code block to get a similar effect.
However, in the case you want a repeatable and reusable chain of events with
shared rescue handling for firing, then this pattern helps.

An example might be you are tracking multiple metric statistics in Rails controller
actions (or via filters).  Perhaps the metrics are important, but in the case of a
new user signup, not so important that you should fail the action should any of the
metrics tracking or other notifications fail.

```ruby
on_event = OnEvent.new(:signup_success) do |oe|
  oe.on_signup_success do |new_user|
    Mailer.notify_admins(new_user)
  end

  oe.on_signup_success do |new_user|
    Metrics.increment(new_user)
  end
end
```

If the admin doesn't get the email that somebody signed up, or Redis is unreachable and
your metrics are temporarily unavailable, your user still signs up.

By overriding the `#rescue_handler` in your `OnEvent` class, you can get shared exception
handler should any callback fail.  This could be as simple as call to `Rails.logger.error`,
or trigger Airbrake but still swallowing the exception.

Often these callbacks are packaged into lifecycle on a model;  however, it is sometimes
the case where you only want them firing in the specific context of a controller.  For
instance, if I create a user on the console, I don't need to receive a mail message
about it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
