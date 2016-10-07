require 'CSV'
require 'rake'
require 'fileutils'
require 'json'
require 'Pry'

array =[]


  CSV.foreach("Opps.csv", :headers => true) do |row|
      retrieve = `curl -u {{CapsuleID}}:x -H "Accept:application/json" https://adsupply.capsulecrm.com/api/party/#{row[0]}/history`
      c_retrieve = JSON.parse(retrieve)
      rquery = c_retrieve['history']
      if rquery['@size'].to_i == 1
        if rquery['historyItem']['type'] = 'Note'
          array << [rquery['historyItem']['partyId'], rquery['historyItem']['partyName'], rquery['historyItem']['type'], rquery['historyItem']['entryDate'], rquery['historyItem']['subject'], rquery['historyItem']['note'], rquery['historyItem']['creatorName']]
        end
      elsif rquery['@size'].to_i > 1
        rquery['historyItem'].each do |activity|
          if activity['type'] = 'Note'
            array << [activity['partyId'], activity['partyName'], activity['type'], activity['entryDate'], activity['subject'], activity['note'], activity['creatorName']]
          end
        end
      end
  end

CSV.open("Notes_Rework.csv", "w") do |csv|
  csv << ["PartyID","PartyName","ActivityType","EntryDate","ActivitySubject","ActivityContent","CreatorName"]
  csv << array
end

puts array.inspect

