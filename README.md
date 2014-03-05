# Remo

Remo is an interface for controlling WeMo light switches (and possibly outlets in the future). Unlike other implementations, it does not rely upon `playful` for upnp discovery, which makes it compatible with JRuby. For the moment, Remo leverages Manticore for its HTTP requests, and until that is abstracted, this library is only compatible with JRuby.

## Installation

Add this line to your application's Gemfile:

    gem 'remo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remo

## Usage

You can fetch all lightswitches on your network (providing you've set them up with your smartphone), via:

```ruby
switches = Remo::Switch.all(force_reload=false) #=> [#<Remo::Switch:0x27f33aef @host="192.168.1.11", @name="Kitchen Switch", @port="49154">, #<Remo::Switch:0x51a23566 @host="192.168.1.12", @name="Main Room", @port="49154">, #<Remo::Switch:0x705fe568 @host="192.168.1.10", @name="Bathroom Switch", @port="49153">]
```

Or select a switch by its friendly name:

```ruby
switch = Remo::Switch.find('Kitchen Switch') #=> #<Remo::Switch:0x27f33aef @host="192.168.1.11", @name="Kitchen Switch", @port="49154">
```

Given a Switch instance, you can call the following methods:
```ruby
switch.state #=> ["off","on"]
switch.off? #=> [true,false]
switch.on? #=> [true,false]
switch.on!
switch.off!
switch.toggle!
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
