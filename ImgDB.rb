require 'pp'
require 'rubygems'
require 'sqlite3'
require 'digest/md5'

include SQLite3
include Digest

class DB
	def initialize 
		@db = Database.new("images.db")
		# @db.results_as_hash = true
	end

	def insert id, img, date
		# @db.execute("insert into images (Id, ImgName, MD5) values (#{id}, '#{img}','#{md5}')")
		@db.execute2("insert into images (Id, ImgName, date) values ('#{id}', '#{img}', '#{date}')")
	end

	def insert_not_exists id, img, date
		if !get_it(id, img)
			# p date
			insert id, img, date
		end
	end

	def get_no_md5 limit=nil
		limit ="limit #{limit}" if limit
		@db.execute("select * from images Where md5 is null #{limit}") do |row|
		 	yield row  # row は結果の行で、各列の値が配列で返ってくる
		end
	end

	def get_it id, img
		@db.execute("select * from images where id='#{id}' and imgName='#{img}'").size>0
	end

	def get_last_id
		get_from_ref('last_id')
	end

	def get_max_number
		get_from_ref('max_number')
	end

	def upd_last_id id
		upd_ref 'last_id', id.to_s
	end

	def upd_md5 id, img_name, md5_value
		@db.execute("update images set md5='#{md5_value}' where id='#{id}' and imgName='#{img_name}'")
	end

	def del_it id, img
		@db.execute("delete from images where id='#{id}' and imgName='#{img}'")
	end

	def get_double
		@db.execute("select md5 from images Where md5 is not null group by md5 having count(*)>1") do |row|
		 	yield row
		end
	end

	def get_by_md5 md5
		@db.execute("select id, imgName, date from images Where md5 ='#{md5}' order by date desc, id desc, imgName desc") do |row|
		 	yield row
		end
	end

	protected
	def get_from_ref key
		value=nil
		@db.execute("select value from ref where key='#{key}'") do |row|
			value = row[0]
		end
		value
	end

	def upd_ref key, value
		@db.execute("update ref set value='#{value}' where key='#{key}'")
	end
end

if __FILE__==$0
	db = DB.new

	# PATH = 'photos'
	# Dir["#{PATH}/*"].each{|one|
	# 	if /^photos\/([^_]+)_(.+)$/=~one
	# 		id = $1
	# 		img = $2
	# 		# md5 = MD5.file(one).hexdigest
	# 		# puts "#{id}-#{img}"
	# 		file = File.new(one)
	# 		db.insert_not_exists(id, img, file.mtime)
	# 	else
	# 		puts one
	# 	end
	# }

	# file = File.new('photos/07220_1407812971034_d3295d033639.jpg')
	# p file.atime
	# p file.ctime
	# p file.mtime

	# db.get_10000
	# p db.get "00024","10495108648380420.jpg"
	db.get_no_md5(5){|rec|
		p rec
	}
end