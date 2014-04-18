# Wopr [![Build Status](https://travis-ci.org/ZestFinance/wopr.svg?branch=master)](https://travis-ci.org/ZestFinance/wopr)

WOPR is a toolkit to test your use of Twilio.

## Installation

Add this line to your rails application's Gemfile:

    gem 'wopr'

And then execute:

    $ bundle install
    $ bundle exec rails generate wopr:install

Or install it yourself as:

    $ gem install wopr

## Usage

```
bot(:agent1).should be_on_a_call_with(bot(customer))
bot(:agent1).should be_on_a_call
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
