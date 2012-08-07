# About

This is a simple sinatra application which acts as an API for your pomodoro information from [tomatoi.st](http://tomatoi.st). Currently, it returns your recent pomodoro information in json format.

# Use

It's pretty simple. The app (which is hosted on heroku), is accessible through the following url (http://pomodoro-api.herokuapp.com/tomatoist/(:yourtomatoistusername).json). 

# Sample JSON output 

    
[{"type":"Pomodoro","time":"2012-08-07 04:32:45 +0000"},{"type":"Long Break","time":"2012-08-07 04:32:45 +0000"},{"type":"Pomodoro","time":"2012-08-07 03:33:45 +0000"}]

# Pulling your pomodoro data in through a rake task

This assumes you (1) want to pull in the pomodoro data and save it somewhere (2) that you would like your pomodoro list cleared when you do, thus avoiding duplicate pomodoros from being saved. I assume you're using rails or something similar, if you're writing a rake task. 

    require 'net/http'
    namespace :pomodoro do
      desc "parses pomodoro data and subsequently clears your pomodoro list"
      task parse_then_clear: :environment do
        Rake::Task['pomodoro:parse'].execute
        puts 'parsed out pomodoros'
        Rake::Task['pomodoro:clear'].execute
        puts 'cleared out pomodoros'
      end
      
      desc "parses pomodoro data and saves it to a database of some sort"
      task parse: :environment do
        uri = URI("http://pomodoro-api.herokuapp.com/tomatoist/(your_tomatoist_username).json")
        pomos = Net::HTTP.get_response(uri).body
        ## the following line assumes you're using rails
        pomodoros  = ActiveSupport::JSON.decode(pomos)
        pomodoros.each do |p|
          ## logic for saving the json data into your application, where i assume you have some sort of data structure in place for saving your pomodoros
        end
      end

      desc "clears the pomodoro list so as to avoid duplicates"
      task clear: :environment do
        uri = URI('http://tomatoi.st/(your_tomatoist_username)/reset')
        res = Net::HTTP.post_form(uri, "_method" => "put")
        puts res.body
      end
    end
