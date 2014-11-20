require './ImgDB'

db = DB.new

PATH = 'photos'
Dir["#{PATH}/*"].each{|one|
	if /^photos\/([^_]+)_(.+)$/=~one
		id = $1
		img = $2
		# md5 = MD5.file(one).hexdigest
		# puts "#{id}-#{img}"
		file = File.new(one)
		db.insert_not_exists(id, img, file.mtime)
	else
		puts one
	end
}

# file = File.new('photos/07220_1407812971034_d3295d033639.jpg')
# p file.atime
# p file.ctime
# p file.mtime

# db.get_10000
# p db.get "00024","10495108648380420.jpg"

