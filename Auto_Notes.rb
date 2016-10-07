require "faraday"
require "csv"

@hash = {}
@conn = Faraday.new(:url => "https://app.futuresimple.com")

CSV.foreach('query_result.csv', :headers=> true) do |item|
  #EDIT THE ITEM SELECTION TO MATCH THE ROWS OF THE USER_ID & AUTH TOKEN; THESE ARE SET TO THE DEFAULT OF THE USERS EXPORT
  @hash[item[0]] = item[10]
end

CSV.foreach('notes_leads.csv', :headers=> true) do |row|
  #ADJUST ROW SELECTION TO THE USER_ID OF YOUR CREATED CSV
  token = @hash["#{row[5]}"]
  row[content].encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  response = @conn.post do |request|
    request.url "/apis/common/api/v1/notes.json"
    request.headers["x-futuresimple-token"] = token    
    request.headers["x-pipejump-auth"] = token 
    request.headers["content-type"] = 'application/json'
    request.headers["cache-control"] = 'no-cache'
    #ADJUST ROW SELECTORS AS NECESSARY TO INCLUDE ROWS OF NOTED PARAMETER
    request.body = "{\n    \"note\": {\n      \"noteable_id\": \"#{row[0]}\",\n      \"created_at\": \"#{row[4]}\",\n      \"content\": \"#{row[1]}\",\n      \"noteable_type\": \"Lead\"\n    }\n}"
  end
  puts "#{response.status} - #{response.body}"
end