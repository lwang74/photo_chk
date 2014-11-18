require 'pp'
require 'rubygems'
require 'sqlite3'
require 'digest/md5'

include SQLite3
include Digest

class DB
	def initialize 
		@db = Database.new("images.db")
	end

	def insert id, img, md5
		@db.execute("insert into images (id, img, md5) values (#{id}, '#{img}','#{md5}')")
	end

	def get_10000
		@db.execute("select top 1000 * from images") do |row|
		  p row  # row は結果の行で、各列の値が配列で返ってくる
		end
	end
end

db = DB.new

PATH = 'photos'
Dir["#{PATH}/*"].each{|one|
	if /^photos\/(.+)_(.+)$/=~one
		id = $1
		img = $2
		md5 = MD5.file(one).hexdigest
		db.insert(id, img, md5)
	else
		puts one
	end
}

db.get_10000