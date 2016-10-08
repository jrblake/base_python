require "faraday"
require "csv"

#Establish Connection
def connection 
	Faraday.new(:url => "https://app.futuresimple.com")
end

#PUT Deal_Update
def update_deal_v1(conn, token, id, variable, parameter, cfo)
	response = conn.put do |request|
	    request.url "/apis/sales/api/v1/deals/#{id}.json"
		request.headers["x-futuresimple-token"] = token
		request.headers["content-type"] = 'application/json'
		request.headers["cache-control"] = 'no-cache'
		if cfo.downcase == "yes" || cfo.downcase == "y"
			request.body = "{\n  \"custom_fields\": {\n \"#{parameter}\": \"#{variable}\"\n }\n}"
		else
			request.body = "{\n  \"#{parameter}\": \"#{variable}\"\n}"
		end
	end
end

#PUT Contact_Update
def update_contact_v1(conn, token, id, variable, parameter, cfo)
	response = conn.put do |request|
	    request.url "/apis/crm/api/v1/contacts/#{id}.json"
		request.headers["x-futuresimple-token"] = token
		request.headers["content-type"] = 'application/json'
		request.headers["cache-control"] = 'no-cache'
		if cfo.downcase == "yes" || cfo.downcase == "y"
			request.body = "{\n \"contact\": {\n \"custom_fields\": {\n \"#{parameter}\": \"#{variable}\"\n }\n}\n}"
		else
			request.body = "{\n \"contact\": {\n \"#{parameter}\": \"#{variable}\"\n }\n}"
		end
	end
end

#PUT Lead_Update
def update_lead_v1(conn, token, id, variable, parameter, cfo)
	response = conn.put do |request|
	    request.url "/apis/leads/api/v1/leads/#{id}.json"
		request.headers["x-futuresimple-token"] = token
		request.headers["x-pipejump-auth"] = token
		request.headers["content-type"] = 'application/json'
		request.headers["cache-control"] = 'no-cache'
		if cfo.downcase == "yes" || cfo.downcase == "y"
			request.body = "{\n \"lead\": {\n \"custom_field_values\": {\n \"#{parameter}\": \"#{variable}\"\n }\n}\n}"
		else
			request.body = "{\n \"lead\": {\n \"#{parameter}\": \"#{variable}\"\n }\n}"
		end
	end
end

#Data Inputs
print "---\n"
puts "V1_Token: "
token = gets.chomp
print "\n"
puts "Object Type to Edit: (Lead, Contact, Deal)"
objecttype = gets.chomp
print "\n"
puts "File Name: "
file_path = gets.chomp
print "\n"
puts "Header of Object ID: "
idheader = gets.chomp
print "\n"
puts "Header of Parameter: "
parameterheader = gets.chomp
print "\n"
puts "Is This Parameter A Custom Field: (Y/N)"
cfo = gets.chomp
print "\n"
puts "Base Parameter to Edit: "
parameter = gets.chomp
print "\n"

#Verify Correct Information
print "---\n"
puts "V1_Token: #{token}"
puts "Object Type to Edit: #{objecttype}"
puts "File Name: #{file_path}"
puts "Header of Object ID: #{idheader}"
puts "Header of Parameter: #{parameterheader}"
puts "Is This Parameter A Custom Field: #{cfo}"
puts "Base Parameter to Edit: #{parameter}"
print "---\n\n"
puts "Is This Information Correct? (Y/N)"
verification = gets.chomp
print "\n"

#Establish Counter + Piggybank
counter = 1
piggybank = 0

#Verification
if verification.downcase == "yes" || verification.downcase == "y"
	if objecttype.downcase == "deal" || objecttype.downcase == "d"
		#RowExecution
		CSV.foreach(file_path, headers:true) do |row|
			conn = connection
			idheadernumber = row.index idheader
			pheadernumber = row.index parameterheader
			response = update_deal_v1(conn, token, row[idheadernumber], row[pheadernumber],parameter, cfo)
			puts "#{counter}. (#{response.status}) - #{response.body}"
			print "\n"
			counter = counter + 1
			piggybank = piggybank + 0.15
		end
	elsif objecttype.downcase == "contact" || objecttype.downcase == "c"
		#RowExecution
		CSV.foreach(file_path, headers:true) do |row|
			conn = connection
			idheadernumber = row.index idheader
			pheadernumber = row.index parameterheader
			response = update_contact_v1(conn, token, row[idheadernumber], row[pheadernumber],parameter, cfo)
			puts "#{counter} - #{response.status} - #{response.body}"
			print "\n"
			counter = counter + 1
			piggybank = piggybank + 0.15
		end
	elsif objecttype.downcase == "lead" || objecttype.downcase == "l"
		#RowExecution
		CSV.foreach(file_path, headers:true) do |row|
			conn = connection
			idheadernumber = row.index idheader
			pheadernumber = row.index parameterheader
			response = update_lead_v1(conn, token, row[idheadernumber], row[pheadernumber],parameter, cfo)
			puts "#{counter}. (#{response.status}) - #{response.body}"
			print "\n"
			counter = counter + 1
			piggybank = piggybank + 0.15
		end
	else
		puts "Retry--Incorrect Data Input"
	end
	puts "You owe Jared $#{piggybank}"
	print "\n"
else
	puts "Retry--Incorrect Data Input"
end



