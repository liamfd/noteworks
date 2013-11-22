class Work < ActiveRecord::Base
  belongs_to :group

  has_many :nodes, dependent: :destroy

	def parseText
		markup.each_line do |line|
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			puts line
			#if the occurence of <*> is before the first occurence of " then it's a new
			@angleBracketLocation = line.index(/<.*>/)
			@firstQuoteMark = line.index("\"")
			puts @angleBracketLocation
			puts @firstQuoteMark
			if @angleBracketLocation < @firstQuoteMark #this means it's time to make a new one! must check if it's a child
				puts "Nailed it. Making a new one."
			end
			@withinBrackets = line.match(/<.*>/).to_s
			puts @withinBrackets
			@type = @withinBrackets.match(/<(.*)\./).captures.to_s
			@category = @withinBrackets.match(/\.(.*)>/).captures.to_s
			puts @type
			puts @category
		end
	end

end