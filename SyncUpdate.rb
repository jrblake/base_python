require "basecrm"
require "csv"

client = BaseCRM::Client.new(access_token: "2c2f10ffce67b74f0c3bdbc3d9f2aed9461c02c4a0d5ef27085c3eff9f37f84c")
sync   = BaseCRM::Sync.new(client: client, device_uuid: "rb2")

class Administrator

	def self.validator(acknowledge, sync, file_path, choice)
		if choice.downcase == "fresh sync" || choice.downcase == "freshsync" || choice.downcase == "fresh" || choice.downcase == "sync" 
			Sync.start(acknowledge, sync, file_path)
		elsif choice.downcase == "update"
			Sync.update(acknowledge, sync, file_path)
		elsif choice.downcase == "push" || choice.downcase == "push back" || choice.downcase == "pushback"
			Sync.pushback(acknowledge, sync, file_path)
		end
	end

end

class Sync

	@@csvDB           = []
	@@comprehensiveDB = []
	@@fragileDB       = []
	@@keyDB           = []
	@@finalDB         = []

	#Populate CSV with Leads Data
	def self.start(acknowledge, sync, file_path)
		CSV.open(file_path, "wb") do |row|
			row << [
					"resource",
					"firstname",
					"lastname",
					"email",
					"object_type",
					"event_type",
					"created_at",
					"updated_at"
					]
			sync.fetch do |meta, resource|
				@@comprehensiveDB.push(resource)
				puts resource
				if meta.type == "lead" && meta.sync.event_type == "created"
			  		row << [
			  				resource.id, 
			  				resource.first_name,
			  				resource.last_name,
			  				resource.email,
			  				meta.type,
			  				meta.sync.event_type,
			  				resource.created_at,
			  				resource.updated_at
			  			  ]
			  		meta.sync.acknowledge
			  	else
			  	end
			end
		end
		CSV.foreach(file_path, :headers => true) do |row|
			@@csvDB.push(row)
			@hndate = row.index "updated_at"
			@hnlname = row.index "updated_at"
		end
		@@csvDB.sort {|o1, o2| (o1[@hndate] <=> o2[@hndate]) == 0 ? (o1[@hnlname] <=> o2[@hnlname]) : (o1[@hndate] <=> o2[@hndate])}
		puts @@csvDB
	end

	#Update CSV with Leads Data
	def self.update(acknowledge, sync, file_path)
		@placeholder = []

		CSV.foreach(file_path, :headers => true) do |row|
				@@csvDB.push(row)
		end
		#@@csvDB = CSV.table(filepath).to_a -- Another Way
		@placeholder = @@csvDB.collect {|column| column[0]}
		sync.fetch do |meta, resource|
			@@fragileDB.push(resource)
			if meta.type == "lead"
				puts resource
				@@keyDB.push(resource)
				if @@csvDB.map {|part| part["resource"] == resource.id }
					puts "true"
					

						

						
					end
				else
					puts "false"
					CSV.open(file_path, "a") do |csv|
						row << [
			  				resource.id, 
			  				resource.first_name,
			  				resource.last_name,
			  				resource.email,
			  				meta.type,
			  				meta.sync.event_type,
			  				resource.created_at,
			  				resource.updated_at
			  			   ]
					end
					@@csvDB.push(resource)
					puts resource
				end
				#puts resource
			end
		meta.sync.acknowledge
		end
		puts @@counter
		puts @@csvDB
	end

	#Update Base with CSV Data
	def self.pushback(acknowledge, sync, file_path)
		CSV.foreach(file_path, :headers => true) do |row|
				@@csvDB.push(row)
				row[0] = read_id

				row[1] = read_first_name
				row[2] = read_last_name
				row[3] = read_email
				row[4] = read_type
				row[5] = read_event_type
				row[6] = read_created_at
				row[7] = read_updated_at


		end
	end

end

print "***************\n"
puts "File Path: "
file_path = gets.chomp
print "\n"
puts "Fresh Sync, Update, or Push Back? "
choice = gets.chomp
print "\n"
puts "Acknowledge Changes? (ACK or NACK) "
acknowledge = gets.chomp
print "***************\n"
puts "File Path: #{filepath}"
puts "Action: #{choice}"
puts "Acknowledgement: #{acknowledge}"
print "***************\n\n"
#puts "Is This Information Correct? (Y/N)"
#verification = gets.chomp
print "***************\n"

Administrator.validator(acknowledge, sync, file_path, choice)



