class Work < ActiveRecord::Base
	belongs_to :group

	has_many :nodes, dependent: :destroy
	has_many :links

	ObjectPlace = Struct.new(:model, :id)
	NodeDepth = Struct.new(:node_idnum, :depth)

	@@types = [ "Basic",
         "Comparison",
         "Definition",
         "Example",
         "Key",
         "Media"
	]

	def initialize
		super
  		@tester = "shoe"
  		@ordering = []
 	end

	before_save :before_save_checker

	#bottom, private
  	def before_save_checker 
   		if markup_changed?
   			parseText
   		end
	end

	def modifyElement(line_number, line_content)
		my_node = self.nodes.first
		my_note = my_node.notes.first
		my_note.body = line_number.to_s + line_content
		#@note.body = (0...8).map { (65 + rand(26)).chr }.join
		#if (@note.body = "$*****")
		#	@note.body = "$";
		#end
		puts my_note.body
		my_note.save
		return my_note
	end
	
	def printOrdering
		@ordering.each {|item| puts(item)}
	end

	#find a way to avoid doing this every time, preferably using instance variables
	def populateOrdering
		@ordering = Array.new
		self.nodes.each do |node|
			@ordering.push(ObjectPlace.new("node", node.id))
			#puts "node" + node.id.to_s
			node.notes.each do |note|
				@ordering.push(ObjectPlace.new("note", note.id))
				#puts "note" + note.id.to_s
			end
		end
	end
	#@ordering = []
	def parseText
		Node.destroy_all(work_id: self.id)
		stack = Array.new
		@ordering = Array.new

		markup.each_line do |line|
			#puts "\n--------\n"
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
			@firstChar = line.match(/[ ,\t]*(.)/).captures.first

			#if a new node should be made
			if @firstChar == '<'
				@withinBrackets = line.match(/<.*>/).to_s
				#puts @withinBrackets

				#get type, convert it to a constant
				@type = @withinBrackets.match(/<(.*)\./).captures.first
				@type[0] = @type[0].capitalize
				if @@types.include? @type
					@type = (@type + "Node")
				else
					@type = "BasicNode"
				end
				puts @type

				@const_type = @type.constantize
				@new_node = @const_type.new()

				#get the category string, use it to pull a category id
				#puts @category
				@category = @withinBrackets.match(/\.(.*)>/).captures.first
				@category_id = 0
				Category.all.each do |cat|
					if (@category.downcase) == (cat.name).downcase
						@category_id = (Category.where("name = ?", cat.name).first).id
					end
				end
				if @category_id == 0
					@category_id = (Category.where(name: "Uncategorized").first).id
				end
				@new_node.category_id = @category_id
				puts @category_id

				@title = line.match(/>(.*)/).captures.first
				@title = @title.strip	
				#puts @title
				@new_node.title = @title
				@new_node.work_id = self.id
				@new_node.save

			#	@obj = ObjectPlace.new("node", @new_node.id)
			#	@ordering.push(@obj)

				@ordering.push(ObjectPlace.new("node", @new_node.id))

				#get the parent.
				@whitespace = line.match(/(.*)</).captures.first
				#puts @whitespace.length #should round this up to the nearest 3, resave it somehow, to make it clear
				@depth = (@whitespace.length)/3 #+2?

				@newNodeDepth = NodeDepth.new(@new_node.id, @depth)
				#if it's a base element
				if @depth == 0
					stack.push(@newNodeDepth)
				else
					@currNodeDepth = stack.pop
					while @depth <= @currNodeDepth.depth do #while you're less deep, therefore it aint yo momma 
						@currNodeDepth = stack.pop
					end #at this point, @currNodeDepth is the nearest element that's not as deep as the new one, it's parent
					@parentNode = Node.find(@currNodeDepth.node_idnum)

					#creates the link, and the sets the parent and child relation
					@relation = Link.new(child_id: @new_node.id, parent_id: @parentNode.id, work_id:self.id)
					@relation.save
					@new_node.parent_relationships << @relation
					@parentNode.child_relationships << @relation

					stack.push(@currNodeDepth)#push the parent back in, in case it has siblings
					stack.push(@newNodeDepth)#push self in, in case it has children

					#@new_node.parent_relationships.build(child_id: @new_node.id, parent_id:@parentNode.id)
					#@new_node.parents << @parentNode
					#@parent_node.child=
					#make this nodes id into the parents child.
					#make the child's parent the parentNode's id.
				end

				#somehow have to break this up such that it says 3 whitespace = 1 tab. 
				#ah, but the javascript will do that for me.

			#if it's a note
			elsif @firstChar == '-'
				@content = line.match(/-(.*)/).captures.first
				
				@parentNodeDepth = stack.pop
				@parent = Node.find(@parentNodeDepth.node_idnum)

				@new_note = Note.new()
				@new_note.body = @content
				@new_note.node_id = @parent.id
				@new_note.save

				@parent.add_note_to_combined(@new_note)

				@ordering.push(ObjectPlace.new("note", @new_note.id))
				stack.push(@parentNodeDepth)
				
			#for special chars
			elsif @firstChar == ':'
				puts "colontown!"

			else
				#this currently does the same as the dash
				@content = line.match(/-(.*)/).captures.first
				
				@parentNodeDepth = stack.pop
				@parent = Node.find(@parentNodeDepth.node_idnum)

				@new_note = Note.new()
				@new_note.body = @content
				@new_note.node_id = @parent.id
				@new_note.save

				@parent.add_note_to_combined(@new_note)

				@ordering.push(ObjectPlace.new("note", @new_note.id))
				stack.push(@parentNodeDepth)
			end
		end
		@ordering.each {|item| puts(item)}
	end

end