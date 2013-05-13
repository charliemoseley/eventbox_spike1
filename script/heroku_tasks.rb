#!/usr/bin/env ruby

# Originally taken from http://antonzolotov.com/2012/03/04/rails-scripts-clone-heroku-database-to-development.html
# Modified to suit Microryza's development environment

module Heroku
  class Db < Thor
    method_option :keep,   type: :boolean, default: false
    method_option :remote, type: :string,  default: "production"
    method_option :host,   type: :string,  default: "localhost"
    method_option :user,   type: :string,  default: "misu"
    method_option :dbname, type: :string,  default: "eventbox_development"
    method_option :dump,   type: :string,  default: "latest.dump"
    method_option :app,    type: :string,  default: "eventbox"
    
    desc "clone", "clone a remote heroku database to the local environment"
    def clone
      puts "Cloning production database to local environment. This might take a few minutes.\n"
      puts "(1/4) capturing #{options[:remote]} database snapshot..."
      puts `heroku pgbackups:capture --expire --app #{options[:app]} --remote #{options[:remote]}`
      puts "(2/4) downloading snapshot..."
      puts `curl -o #{options[:dump]} \`heroku pgbackups:url --app #{options[:app]} --remote #{options[:remote]}\``
      puts "(3/4) restoring snapshot..."
      puts `pg_restore --verbose --no-acl --clean --no-owner -n public -h #{options[:host]} -U #{options[:user]} -d #{options[:dbname] || dbname} #{options[:dump]}`
      unless options[:keep]
        puts "(4/4) cleaning up..."
        puts `rm #{options[:dump]}`
      else
        puts "(4/4) skipping cleaning..."
      end
    end
    
    method_option :remote, type: :string,  default: "production"
    method_option :app,    type: :string,  default: "eventbox"
    method_option :staging_app, type: :string, default: "eventbox_staging"
    
    desc "update_staging", "update staging with production database"
    def update_staging
      puts "Updates staging database to be the same as production.  This might take a few minutes.\n"
      puts "(1/3) capturing #{options[:remote]} database snapshot..."
      puts `heroku pgbackups:capture --expire --app #{options[:app]} --remote #{options[:remote]}`
      puts "(2/3) restoring snapshot..."
      puts `heroku pgbackups:restore DATABASE \`heroku pgbackups:url --app #{options[:app]}\` --app #{options[:staging_app]} --confirm #{options[:staging_app]}`
      puts "(3/3) clearing cache...[WIP]"
      #puts `heroku run --app #{options[:staging_app]} rails runner \"Rails.cache.clear\"`
    end

    no_tasks do
      def dbname
        YAML.load_file('config/database.yml')["development"]["database"]
      end
    end
  end
end