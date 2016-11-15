require 'Faraday'
require 'csv'
require 'io/console'
require 'json'
require 'colorize'

parameter_hash    = {}

#Establish Connection
def connection
  Faraday.new(:url => "https://api.getbase.com")
end

#Initiate Web Request
def request(conn, token, id, parameters, object)
  response = conn.put do |call|
    call.url "/v2/#{object}/#{id}"
    call.headers["Authorization"] = "Bearer #{token}"
    call.headers["accept"] = 'application/json'
    call.headers["content-type"] = 'application/json'
    call.headers["cache-control"] = 'no-cache'
    call.body = parameters
  end
end

#Read Values from CSV & Create Corresponding JSON Request Body
def csv_input(inputfile, token, id_header, hash, object)
  conn = connection
  counter = 1
  CSV.foreach(inputfile, headers:true).with_index do |row, index|
    idheadernumber = row.index id_header
    id = row[idheadernumber]
    request_body = {}
    nf_hash      = {}
    cf_hash      = {}
    cf_finalhash = {}
    ms_array     = []
    hash.each do |key, value|
      if value == 'CustomField'
        input = row.index key
        cf_hash[key] = "#{row[input]}"
      elsif value == 'CustomField.Number'
        input = row.index key
        cf_hash[key] = row[input].to_i
      elsif value == 'CustomField.Multi-Select'
        input = row.index key
        ms_array << row[input].to_s
        cf_hash[key] = ms_array
      elsif value == 'NativeField'
        csvinput = row.index key
        nf_hash[key] = "#{row[csvinput]}"
      end
    end
    cf_finalhash["custom_fields"] = cf_hash
    request_body["data"] = nf_hash.merge(cf_finalhash)
    response = request(conn, token, id, request_body.to_json, object)
    if response.status == 200
      puts "#{counter} - #{response.status}: #{response.body}\n".green
    else
      puts "#{counter} - #{response.status}: #{response.body}\n".red
    end
    counter += 1
  end
end

#User Input
puts "V2 - OAuth_Token: "
token = STDIN.noecho(&:gets)
print "\n"
puts "Input File Name: "
while file_name = gets.chomp
  break if file_name.include?(".csv")
  puts "ERROR: Ensure File Name Includes .CSV Extension"
end
print "\n"
puts "Object Type to Edit: (Leads, Contacts, Deals)"
while object = gets.chomp
  object.downcase!
  break if (object == 'leads' || object == 'contacts' || object == 'deals')
  puts "ERROR: Re-Enter Object Type to Edit: (Leads, Contacts, Deals)"
end
print "\n"
puts "Header Containing Object ID: "
idheader = gets.chomp
print "\n"
puts "Header Containing Parameter: "
while pheader = gets.chomp
  break if (pheader.chomp == '')
  puts "Is This Parameter A Custom Field: (Y/N)"
  cf_input = gets.chomp
  cf_input.capitalize!
  if cf_input == 'Yes' || cf_input == 'Y'
    cf_input = 'CustomField'
    puts "Is This Parameter A Field-Type of Number: (Y/N)"
    n_input = gets.chomp
    n_input.capitalize!
    if n_input == 'Yes' || n_input == 'Y'
      cf_input = 'CustomField.Number'
    else
      puts "Is This Parameter A Field-Type of Multi-Select: (Y/N)"
      ms_input = gets.chomp
      ms_input.capitalize!
      if ms_input == 'Yes' || ms_input == 'Y'
        cf_input = 'CustomField.Multi-Select'
      else
        cf_input = 'CustomField'
      end
    end
  elsif cf_input == 'No' || cf_input == 'N'
    cf_input = 'NativeField'
  end
  parameter_hash[pheader] = cf_input
  print "\n"
  puts "Enter Another Header Containing A Parameter: (Hit 'Enter' to Exit)"
end
puts "Name of Base Field => Field Type\n"
puts parameter_hash

csv_input(file_name, token, idheader, parameter_hash, object)
