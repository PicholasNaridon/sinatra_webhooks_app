require 'rubygems'
require 'bundler/setup'
require 'tinypass'
require 'sinatra'
require 'json'
require 'httpclient'


Tinypass::ClientBuilder.new
Tinypass.sandbox = true # fill in true or false
Tinypass.aid = '' # fill in AID
Tinypass.private_key ='' # fill in API private Key

aid = Tinypass.aid
api_token = '' # fill in API token

def get_payment_id(api_token, aid, uid, rid)
 url = 'https://sandbox.tinypass.com/api/v3/publisher/conversion/lastAccess'
 data = {
   "api_token" => api_token,
   "aid" => aid,
   "uid" => uid,
   "rid" => rid
 }
  client = HTTPClient.new.get(url, data)
  body = JSON.parse(client.body)
  payment_id = body["conversion"]["user_payment"]["user_payment_id"].to_s
  return payment_id
end

def send_receipt(api_token, aid, user_pay_id)
 url = 'https://sandbox.tinypass.com/api/v3/publisher/payment/resendReceipt'
 data = {
   "api_token" => api_token,
   "aid" => aid,
   "user_payment_id" => user_pay_id
 }
 client = HTTPClient.new.get(url, data)
  return client.body
end


get "/webhooks" do
  if (params.has_key?(:data))
    decrypt = Tinypass::SecurityUtils.decrypt(Tinypass.private_key, params[:data])
  end
  response = JSON.parse(decrypt)
  if response["event"] == "subscription_auto_renewed" || response["event"] =="new_purchase"
    id = get_payment_id(api_token, aid, response["uid"], response["rid"])
    send_receipt(api_token, aid, id) #sends the email
  else
    return "didn't do shit" # sad path
  end
end
