class Distribution
	attr_accessor :total_object_number
	# distribution types
	RANDOM=0 #(default)
	SEQUENTAL=1
	def initialize(dist_hash) # {status_name => status_probability (in percents)}
		@distribution=dist_hash
		@type=RANDOM
		@sequental_increment=1
		@sequental_index=@sequental_increment
		# check for consistency
		raise "Distribution init error > summ of percents must be 100" if @distribution.values.inject{|sum,x| sum + x }!=100
 	end

	def type(type,total_object_number=nil)
		raise "Unknown type: #{type}. Possible types are Distribution::RANDOM, Distribution::SEQUENTAL" if not (type==RANDOM or type==SEQUENTAL)
		@type=type
		if @type==SEQUENTAL
			raise "SEQUENTAL type requires the total number of objects that will be generated (>0)" if (total_object_number==nil or total_object_number==0)
			@sequental_increment=(100/total_object_number).floor
			@sequental_index=@sequental_increment
		end
	end

	def generate
		r=(@type==RANDOM)? rand(100) : @sequental_index
		@sequental_index=(@sequental_index<100)? @sequental_index+@sequental_increment : @sequental_increment
		dist_ary=@distribution.values
		dist_ary_normalized=[]
		dist_ary_normalized << dist_ary.first
		for i in 1..dist_ary.length-1
			dist_ary_normalized[i]=dist_ary_normalized[i-1]+dist_ary[i]
		end
		ind=(dist_ary_normalized << r).sort!.index(r)
		return @distribution.keys[ind]
	end
end

#d=Distribution.new('new'=>10,'old'=>30,'very_old'=>60)
#d.type(Distribution::SEQUENTAL,10)
#10.times do
#	puts d.generate
#end
