require 'sinatra'

class Webapp < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/webapp'
end

run Webapp