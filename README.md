# Flox Tools for Ruby

[![Gem Version](https://badge.fury.io/rb/flox.png)](http://badge.fury.io/rb/flox)

## What is Flox?

Flox is a server backend especially for game developers, providing all the basics you need for a game: analytics, leaderboards, custom entities, and much more. The focus of Flox lies on its scalability (guaranteed by running in the Google App Engine) and ease of use.

While you can communicate with our servers directly via REST, we provide powerful SDKs for the most popular development platforms, including advanced features like offline-support and data caching. With these SDKs, integrating Flox into your game is just a matter of minutes.

More information about Flox can be found here:
[Flox, the No-Fuzz Game Backend](http://www.flox.cc)

## How to install the Flox Gem

Flox is distributed as a Ruby Gem, so you can install it just like any other gem:

    gem install flox

## How to use the Ruby API

The Ruby client is designed to be used not in games, but in scripts that help you operate your games. You can use it e.g. to automatically download your leaderboards or certain entities for backup. It's also easy to utilize Flox via 'irb', allowing quick introspection into your server data.

To start up, create a Flox instance with your game id and key:

    flox = Flox.new('game-id', 'game-key')

Most of the time, you'll also need to login as a 'Hero'. A hero is a special Flox player that has super-user rights. Create a hero in the Flox interface and note down its 'key'.

    flox.login_with_key('hero-key')

We're done with the preparations! Now let's look at some of the things you can do.

### Working with Entities

    # load an entity with a certain type and id
    entity = flox.load_entity('entity-type', 'entity-id') # => Flox::Entity

    # modify it via the []-operator
    entity['myProperty'] = 'something'

    # save or delete at will
    flox.save_entity(entity)
    flox.delete_entity(entity)

### Accessing leaderboards

    # load scores from a leaderboard
    scores = flox.load_scores('leaderboard-id', :today) # => Array of Flox::Score
    best_score = scores.first.value
    best_player_id = scores.first.player_id

### Loading logs

    # load all logs from a certain day that contain a warning or error
    logs = flox.load_logs('day:2014-02-22 warning')
    num_logs = logs.length
    logs.each { |log| puts log['duration'] }

## Where to go from here:

This is just the tip of the iceberg! Have a look at the complete API Reference to find out what's possible. New features will be added regularly!
