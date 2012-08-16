#!/usr/bin/ruby
require 'time'

if ARGV.length < 1
	puts 'Options:'
	puts '    load: resets the post mod times to what ever is saved in times.txt'
	puts '    save: saves the current post\'s times into times.txt'
else
	if ARGV[0] == "load"				
		if File.exists?('times.txt')
			fileStr = File.open('times.txt', 'r') {|file| file.read}

			fileStr.split("\n").each do |line|
				fileName = line.split("\t")[0]
				fileTime = line.split("\t")[1]
				File.utime(Time.parse(fileTime), Time.parse(fileTime), fileName)
			end
		else
			puts 'Times don\'t exist, please run save first'
		end				
	elsif ARGV[0] == "save"
		fileTimes = ""
		@files = Dir.glob('public/posts/*.md')
		
		for file in @files
			fileTimes += file + "\t" + File.mtime(file).to_s
			fileTimes += "\n"			
		end	

		File.open('times.txt', 'w+').write(fileTimes)
	end
end