require 'bundler/setup'
Bundler.require

# require 'sinatra'
# require 'rack/ssl'

# use Rack::SSL
# set :public_folder, './public'
# set :ip, '0.0.0.0'

# get '/hi' do
#   "Hello World!"
# end


require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'JSON'

webrick_options = {
        :Port               => 8442,
        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        #:SSLEnable          => true,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
}
@@db = SQLite3::Database.new "db.db3"

class MyServer  < Sinatra::Base
  set :public_folder, './public'

  get '/hi' do
    "Hello World!"
  end 

  get '/pos' do
    File.open('geo_point.gpx', 'w') { |file| file.write(%Q{<gpx><wpt lat="#{params[:lat]}" lon="#{params[:lng]}"></wpt></gpx>}) }
    `osascript click_menu.applescript`
    "OK"
  end

  get '/previous_location' do
    open('geo_point.gpx').read.match(/lat="([^"]+)" lon="([^"]+)"/)
    content_type :json
    {lat: $1.to_f, lng: $2.to_f}.to_json
  end

  get '/my_locations' do
    locations = @@db.execute( "select id, title, lat, lng from locations" ).inject([]) {|res, row| res.push({id: row[0], title: row[1], lat: row[2], lng: row[3]}) }
    content_type :json
    {results: locations}.to_json
  end  

end



Rack::Handler::WEBrick.run MyServer, webrick_options