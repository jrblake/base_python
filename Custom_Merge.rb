names = File.read("./data", :encoding => "UTF-8").split("\n").inject([]) do |memo, name|
   memo << name.split("|").map(&:strip).map(&:downcase)
end
 

names_to_merge = names.inject({}) do |memo, triple|
  if memo[[triple.first, triple[1]]]
    memo[[triple.first, triple[1]]] << triple[2]
    memo
  else
    memo[[triple.first, triple[1]]] = [triple[2]]
    memo
  end
end
 
ids_to_merge = names_to_merge.map { |_, v| v }
 
require "faraday"

conn = Faraday.new(:url => "https://app.futuresimple.com")
ids_to_merge.each do |ids|
    ids.each_slice(5) do |sliced|
    a = conn.post do |req|
      req.url "/apis/crm/api/v1/contacts/merge.json"
      req.headers['content-type'] = 'application/json'
      req.headers["x-futuresimple-token"] = token
      req.body = "{ \"contact_ids\": \"#{sliced.join(",")}\" }"
    end
  p a.body
  end
end