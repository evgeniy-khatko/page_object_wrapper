require 'Exceptions'

class Pagination

	def initialize(page_object,pagination_div_args)
		page_numbers=[]
		link_pattern=''
		@pagination_links=[]
		@page_object=page_object
		@accessor=@page_object.class.accessor
		@base_url=@page_object.class.url
		if @accessor.div(pagination_div_args).exists?
			raise ArgumentError.new("Cant find ul list inside div #{pagination_div_args.inspect} on page #{@accessor.url}") if not @accessor.div(pagination_div_args).ul.exists?
			raise ArgumentError.new("Pagination link not found inside div #{pagination_div_args.inspect} on page #{@accessor.url}") if @accessor.div(pagination_div_args).ul.links.to_a.empty?
			@accessor.div(pagination_div_args).ul.links.each{|l| 
				if l.text=~/\d/
					page_numbers << l.text.to_i 
					@link_pattern=l.href
				end
			}
			page_numbers.collect(&:to_i).sort!
			for i in page_numbers.first..page_numbers.last do
				@pagination_links << @link_pattern.gsub(/=\d+/,"="+i.to_s)
			end
		else
			# assuming that page has no pagination links
			@pagination_links << @base_url
			@link_pattern=@base_url
		end
	end

	def number(n)
		raise ArgumentError.new("Cant find pagination page number #{n} on Page #{@accessor.url}") if not @pagination_links.include?(@link_pattern.gsub(/=\d+/,"="+(n).to_s))
		change_page(@pagination_links[n-1])
	end

	def first
		change_page(@pagination_links.first)
	end
	def last
		change_page(@pagination_links.last)
	end
	def reset
		change_page(@base_url)
	end
	def each
		@pagination_links.each{|link| 
			p=change_page(link)
			yield p
		}
	end
		

private
	def change_page(link)
		@page_object.class.url=link
		@page_object.class.new(true)
	end
end
