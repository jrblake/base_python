require 'faraday'
require 'csv'
require 'io/console'

call = {}

def connection
  Faraday.new(:url => 'https://app.futuresimple.com')
end

def post_request(connection, action, endpoint, token, body)
  response = connection.action do |request|
    request.url '/apis/#{endpoint}'
    request.headers['x-futuresimple-token'] = token
    request.headers['x-pipejump-auth'] = token
    request.headers['content-type'] = 'application/json'
    request.headers['accept'] = 'application/json'
    request.headers['cache-control'] = 'no-cache'
    request.body = body
  end
end

def request_selector(object_type, request_type, call)
  if object_type.downcase == 'lead'

end

