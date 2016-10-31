require 'rake'
require 'fileutils'
require 'find'
require 'CSV'

mapping = []

=begin

MAKE SURE TO ADD BOTH THE ATTACHMENT.CSV + SCRIPT TO THE ATTACHMENTS FOLDER BEFORE EXECUTING

=end
CSV.open("mapping.csv", "w") do |csv|

  #SET MAPPING CSV HEADERS
  csv << ["Account_ID", "Filepath"]

  CSV.foreach('Attachment.csv', :headers=> true) do |row|
    #BASH COMMAND TO FIND FILE EXTENSION
    cmd = `file #{row[0]}`

    #SET EXTENSION VAR
    if cmd.include? "PDF document"
      extension = "pdf"
    elsif cmd.include? "PNG image"
      extension = "png"
    elsif cmd.include? "JPEG image"
      extension = "jpeg"
    elsif cmd.include? "vCalendar calendar"
      extension = "vcs"
    elsif cmd.include? "JPG image"
      extension = "jpg"
    elsif cmd.include? "Zip archive"
      extension = "zip"
    elsif cmd.include? "GIF image"
      extension = "gif"
    elsif cmd.include? "TXT document"
      extension = "txt"
    elsif cmd.include? "DOC document"
      extension = "doc"
    end

    #RENAME FILE
    filename = row[4].split(".")[0]
    File.rename(row[0], "#{filename}.#{extension}")

    #OUTPUT CHANGES MADE
    puts row[0] + " => #{filename}.#{extension}"

    #CREATE CSV MAPPING TO PUSH TO BASE
    csv << [row[3], "#{filename}.#{extension}"]
  end
end


