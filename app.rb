require 'rubygems'
require 'bundler/setup'
require 'tinypass'


# myapp.rb
require 'sinatra'
require 'json'

Tinypass::ClientBuilder.new
Tinypass.sandbox = true
Tinypass.aid = ''
Tinypass.private_key =''

get "/webhooks" do
  if (params.has_key?(:data))
    decrypt = Tinypass::SecurityUtils.decrypt('', params[:data])
  end
   decrypt


end
