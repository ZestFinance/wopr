# Wopr

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'wopr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wopr

## Usage

### For cucumber
add a file `features/support/wopr.rb` with a following content
```ruby
Wopr.configure do |config|
  config.twilio_server_port   = <port_for_twilio_callbacks>
  config.twilio_callback_host = <publicly_accesible_host_for_twilio_callbacks>
  config.twilio_account_sid   = <your_twilio_account_sid>
  config.twilio_auth_token    = <your_twilio_token>
end

Wopr.boot
```

### Now you can do
```
bot(:agent1).should be_on_a_call_with(bot(customer))
bot(:agent1).should be_on_a_call
```

TODO: bot setup instructions

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
