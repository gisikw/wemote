# Wemote [![Build Status](https://travis-ci.org/gisikw/wemote.png)](https://travis-ci.org/gisikw/wemote) [![Gem Version](https://badge.fury.io/rb/wemote.png)](http://badge.fury.io/rb/wemote) [![Coverage Status](https://coveralls.io/repos/gisikw/wemote/badge.png)](https://coveralls.io/r/gisikw/wemote)

Wemote is an interface for controlling WeMo light switches (and possibly outlets in the future). Unlike other implementations, it does not rely upon `playful` for upnp discovery, which makes it compatible with alternative Ruby engines, such as JRuby.

## Installation

Add this line to your application's Gemfile:

    gem 'wemote'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wemote

## Usage

You can fetch all lightswitches on your network (providing you've set them up with your smartphone), via:

```ruby
switches = Wemote::Switch.all(force_reload=false) #=> [#<Remo::Switch:0x27f33aef @host="192.168.1.11", @name="Kitchen Switch", @port="49154">, #<Remo::Switch:0x51a23566 @host="192.168.1.12", @name="Main Room", @port="49154">, #<Remo::Switch:0x705fe568 @host="192.168.1.10", @name="Bathroom Switch", @port="49153">]
```

Or select a switch by its friendly name:

```ruby
switch = Wemote::Switch.find('Kitchen Switch') #=> #<Remo::Switch:0x27f33aef @host="192.168.1.11", @name="Kitchen Switch", @port="49154">
```

Given a Switch instance, you can call the following methods:
```ruby
switch.get_state #=> [:off,:on]
switch.off? #=> [true,false]
switch.on? #=> [true,false]
switch.on!
switch.off!
switch.toggle!
```

## Performance

Wemote is designed to be performant - and as such, it will leverage the best HTTP library available for making requests. Currently, Wemote will use (in order of preference): `manticore`, `typhoeus`, `httparty`, and finally (miserably) `net/http`. Because you probably like things fast too, we recommend you `gem install manticore` on JRuby, or `gem install typhoeus` on another engine. In order to keep the gem as flexible as possible, none of these are direct dependencies. They just make Wemote happy and fast.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
