class Post
	attr_accessor :title, :content, :date, :url

	def initialize(title, content, date, url)
		coderayified = CodeRayify.new(:filter_html => true, :hard_wrap => true)
		options = 
		{
			:fenced_code_blocks => true,
			:no_intra_emphasis => true,
			:autolink => true,
			:strikethrough => true,
			:lax_html_blocks => true,
			:superscript => true
		}
		
    markdown_to_html = Redcarpet::Markdown.new(coderayified, options)
		
		@title = title
		@content = markdown_to_html.render(content).html_safe
		@date = date
		@url = url
	end
	
	def self.loadPost(name)		
		begin
			file = File.new("public/posts/" + name + ".md", "r")
			content = ""
			while (line = file.gets)
				content += line
			end
			time = file.ctime.strftime("%d %B %Y at %H:%M:%S")

			file.close	
			return Post.new(name, content, time, name.downcase.gsub(/[^a-z0-9_-]/, ""))
		rescue => err
			return nil
		end
	end
end