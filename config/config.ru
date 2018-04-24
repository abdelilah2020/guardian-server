require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['ENV'] || 'development')
require 'sinatra/base'
require 'sinatra/json'
require 'rack/contrib'
require 'rack/mount'
require 'require_all'

require_rel '../lib/requirer.rb'
require_rel '../lib/sinatra'

run GuardianSinatraApp
