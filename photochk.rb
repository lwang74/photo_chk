require 'mechanize'
require 'json'
require 'FileUtils'
require './ImgDB'

class MyPhoto
	def initialize top_path
		@top_path = top_path
		@agent = Mechanize.new
		@agent.user_agent_alias = "Windows IE 9"
		# url = 'http://photo.app887.com/download.html'
		# post_url = "resourcev2/DownloadFile.action?id=07240"  

		@agent.set_proxy('127.0.0.1', 3128)
		@agent.pluggable_parser.default = Mechanize::Download
		# page = agent.get(url)
		# pp page
		# @curr = {}
		@max_thread = 20
		@q = Queue.new
		@MAX_NUM = 99999
		@db = DB.new
	end

	def download_auto
		start_number = @db.get_last_id().to_i
		number_len = @db.get_max_number().to_i
		download(start_number, number_len)
	end

	def download start_number, number_len
		download_img_worker @max_thread

		# to_number = start_number+number_len
		# while start_number<=to_number
		# 	number_str = to_s_5(start_number)
		# 	url_arr = get_one_id(number_str)
		# 	download_img(url_arr, number_str)
		# 	sleep 5 while @q.size>@max_thread
		# 	start_number+=1
		# end

		curr = start_number
		while number_len>0
			new_num = get_number(curr)
			number_str = to_s_5(new_num)
			url_arr = get_one_id(number_str)
			download_img(url_arr, number_str)
			sleep 5 while @q.size>@max_thread

			curr += 1
			number_len -= 1
		end

		sleep 10
	end

	protected
	def get_number curr_number
		if curr_number>@MAX_NUM
			curr_number-@MAX_NUM
		else
			curr_number
		end
	end

	def to_s_5 to_number
		max_len = 5
		str = to_number.to_s
		str = '0'*(max_len-str.size)+str if str.size<max_len
		str
	end 

	def get_one_id id #07024
		begin
			page1 = @agent.post('http://photo.app887.com/resourcev2/DownloadFile.action', {'id'=>"#{id}"})
			bady=page1.body
			result = JSON.parse(bady)
			result['files'].map{|one|
				one['url']
			} if result['files']
		rescue Exception => e
			sleep 20
			puts 'retry'
			# p e.message
			retry
		end
	end

	def download_img url_arr, id
		if url_arr and url_arr.size>0
			url_arr.each{|img_src|
				if /([^\/]+\.jpg)$/i=~img_src
					# puts "#{id} : #{img_src}"
					img_file = $1
					@q.push [id, img_src, img_file]
					sleep 0.1
				end
			}
		end
	end

	def download_one_image id, img_src, img_file, thread_no
		begin
			# local_file = "photos/#{id}_#{img_file}"
			# if !File.exists?(local_file)
			if !@db.get_it(id, img_file)
				now = Time.new
				# local_path = "photos_"
				# local_file = ""
				# if /^(\d{4}\-\d{2}\-\d{2})\s/=~now.to_s
				# 	date = $1
				# 	local_path += "#{date}"
				# 	local_file = "#{local_path}/#{id}_#{img_file}"
				# else
				# 	puts "*** Time format error!"
				# end

				local_path = "#{@top_path}/#{now.strftime("photos_%Y-%m-%d")}"
				local_file = "#{local_path}/#{id}_#{img_file}"

				@db.insert_not_exists(id, img_file, now)
				@db.upd_last_id(id)
				FileUtils.mkdir_p local_path

				# p img_src
				@agent.get(img_src).save(local_file)
				puts "#{thread_no}:#{id} => #{img_file}"
			end
		rescue Exception => e
			# p e
		end
	end

	def download_img_worker t
		workers = []
		t.times { |j|
		  workers << Thread.start {
		    loop {
			    one = @q.pop
			    download_one_image one[0], one[1], one[2], j
				# sleep 0.1
		    }
		  }
		}
	end
end

# if ARGV.size==2
# 	myP = MyPhoto.new
# 	myP.download ARGV[0].to_i, ARGV[1].to_i
# end
if ARGV.size==0
	myP = MyPhoto.new('D:/lwang/photos')
	myP.download_auto
end

# now = Time.new
# p FileUtils.mkdir_p "photos_2014-11-20"
