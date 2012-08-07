# About

This is a simple sinatra application which acts as an API for your pomodoro information from [tomatoi.st](http://tomatoi.st). Currently, it returns your recent pomodoro information in json format.

# Use

It's pretty simple. The app (which is hosted on heroku), is accessible through the following url (http://pomodoro-api.herokuapp.com/tomatoist/(:yourtomatoistusername).json). 

# Pulling your pomodoro data in through a rake task


    require 'net/http'
    namespace :pomodoro do
      desc "parses pomodoro data and subsequently clears your pomodoro list (which is desirable since otherwise you would likely end up with duplicates)"
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
