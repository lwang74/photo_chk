require 'FileUtils'

def process
	path = 'photos'
	Dir["#{path}/*"].each{|one|
		if /([^\/]+\.jpg)/i=~one
			file_name = $1
			file = File.new(one)
			to_path = file.mtime.strftime("photos_%Y-%m-%d")
			file.close
			FileUtils.mkdir_p to_path
			FileUtils.mv one, to_path
			print '.'
		else
			puts "!!!Error #{one}"
		end
	}
end

process
# FileUtils.mv 'photos_2014-12-02/46860_1120732929422926.jpg', 'photos1_2014-12-02'

