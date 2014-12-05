require 'digest/md5'
require './ImgDB'

include Digest

# file = 'd:/lwang/photos/photos_2014-08-12/00015_1408292303.jpg'
# p md5 = MD5.file(file).hexdigest

$top_path = 'd:/lwang/photos'
$db = DB.new

def set_md5 count
	$db.get_no_md5(count){|rec|
		# p rec
		id = rec[0]
		img = rec[1]
		if /^(\d{4}\-\d{2}\-\d{2})\s/ =~ rec[2]
			file = "#{$top_path}/photos_#{$1}/#{id}_#{img}"
			if File.exists?(file)
				fl = File.new(file)
				file_size = fl.size
				fl.close

				if 0==file_size
					puts "size0; #{file}"
					File.delete(file)
					$db.del_it(id, img)
				else
					md5 = MD5.file(file).hexdigest
					$db.upd_md5 id, img, md5
				end
			else
				puts "!!!Not exists! #{file}"
				$db.del_it(id, img)
			end
		else
			puts "!!!Error!!!"
		end
	}
end

class Imgs
	def initialize db, top_path
		@db = db
		@top_path = top_path
	end
	def delete_double
		@db.get_double{|rec|
			puts rec[0]
			cnt = 0
			@db.get_by_md5(rec[0]){|rec1|
				if 0!=cnt
					delete(rec1[0], rec1[1], rec1[2])
				end
				cnt+=1
			}
		}
	end
	protected
	def delete id, img_file, date
		puts "#{id}\t#{img_file}\t#{date}"
		if /^(\d{4}\-\d{2}\-\d{2})\s/ =~ date
			file = "#{@top_path}/photos_#{$1}/#{id}_#{img_file}"
			File.delete(file)
			@db.del_it(id, img_file)
		else
			puts "!!!Error!!!"
		end
	end
end

set_md5 nil
imgs = Imgs.new($db, $top_path)
imgs.delete_double
