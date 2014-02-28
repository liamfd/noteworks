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
		firstChar = line_content.match(/[ ,\t]*(.)/).captures.first
				
		if firstChar == '<'
			deleteElement(line_number)
			insertNewElement(line_number, line_content)
			return self.nodes.first
		elsif firstChar == '-'
			deleteElement(line_number)
			insertNewElement(line_number, line_content)
			return self.nodes.first
		else	
			return self.nodes.first
		end

		#ordering = populateOrdering()
		#if firstChar == '<'
		#	if ordering[line_number].model == "node" #if there was a note
		#		insertNewElement(line_number, line_content, "node")
		#		node = Node.find(ordering[line_number].id)
		#		puts node.title
		#		buildNode(node, line_content)
		#		node.save
		#		return node
		#	elsif ordering[line_number].model == "note" #if it's the other type, delete what was there, insert a new thing
		#		deleteElement(line_number)
		#		insertNewElement(line_number, line_content, "note")
		#	end
		#elsif firstChar == '-'
		#	if ordering[line_number].model == "note"
		#		note = Note.find(ordering[line_number].id)
		#		buildNote(note, line_content)
#
#				note.save
#				#should add the Note to the parent's combined
#				return note #this should really return the parent node, for graph insertion
#			elsif ordering[line_number].model == "node" #if it's the other type, delete what was there, insert a new thing
#				deleteElement(line_number)
#				insertNewElement(line_number, line_content, "node")
#			end
#		else	
#			return "goofed"
#		end
	end
	
	#shouldn't be called until the JS knows what type the new thing is
	#can do that by checking the line each time (after an enter?) and looking for a special char. or just wait till it's typed?
	def insertNewElement(line_number, line_content)
		ordering = populateOrdering()
		first_char = line_content.match(/[ ,\t]*(.)/).captures.first

		if first_char == "<"
			new_node = Node.new
			buildNode(new_node, line_content)
			new_node.save
			ordering.insert(line_number, ObjectPlace.new("node", new_node.id))

			#FIND PARENT
			if new_node.depth != 0 #if it's not a base element
				parent_node = findElParent(new_node.depth, line_number, ordering)
				if parent_node != nil
					relation = Link.new(child_id: new_node.id, parent_id: parent_node.id, work_id: self.id)
					relation.save
					new_node.parent_relationships << relation
					parent_node.child_relationships << relation
				end
			end

			#FIND CHILDREN
			children = findElChildren(line_number, new_node.depth, ordering)
			children.each do |child|
				changeParent(child[:node], new_node)
			end

		else
			new_note = Note.new
			buildNote(new_note, line_content)
			new_note.save
			ordering.insert(line_number, ObjectPlace.new("note", new_note.id))

			#FIND PARENT
			parent_node = findElParent(new_note.depth, line_number, ordering)
			if parent_node != nil
				new_note.node_id = parent_node.id
				parent_node.add_note_to_combined(new_note)
				new_note.save
			end
		end
	end

	def deleteElement(line_number)
		ordering = populateOrdering
		el = getElementInOrdering(line_number, ordering)
		puts(el.id)

		#find elements children, remove element, then have them find new parents
		children = findElChildren(line_number, el.depth, ordering)
		ordering.delete_at(line_number)
		printOrdering(ordering)

		#for each child, find their new parent according to the ordering, update the elements
		children.each do |child|
			new_parent = findElParent(child[:node].depth, child[:index], ordering)
			changeParent(child[:node], new_parent)
		end

		el.delete
	end

	def printOrdering(ordering)
		ordering.each {|item| puts(item)}
	end

	#this could be a find parent function. even just pass it a location and the ordering. works for node and note, both have depth
	def findElParent(el_depth, index, ordering)
		i = index - 1
		while i >= 0 #until the beginning
			if ordering[i].model == "node" #if it's a node, not just a note
				curr_node = Node.find(ordering[i].id)
				if el_depth > curr_node.depth #if curr_node has a lesser depth, it's its parent
					return curr_node
				end
			end
			i = i-1
		end
		return nil #if no parent found
	end

	#returns a collection of all the children of an element at a line, given its line, a depth, and an ordering
	def findElChildren(index, el_depth, ordering)
		children = Array.new
		i = index + 1
		curr_el = getElementInOrdering(i, ordering)
		if curr_el.is_a?(Node)
			curr_child_depth = curr_el.depth
		else #if it's a note, it can't have children, so arbitrary big depth that'll get rest on the first node
			curr_child_depth = 100000
		end

		while (curr_el != nil && el_depth < curr_el.depth) #until you find something of equal or lesser depth
			puts curr_el
			#basically, include it if it's nested deeper (therefore in this loop,) but don't go into children of what you find)
			if curr_el.depth <= curr_child_depth && curr_el.is_a?(Node)
				node_and_index = { node: curr_el, index: i}
				children.push(node_and_index)
				curr_child_depth = curr_el.depth
			elsif curr_el.depth <= curr_child_depth && curr_el.is_a?(Note)
				node_and_index = { node: curr_el, index: i}
				children.push(node_and_index)
			end
			#if there's an indented note after some nodes, it will likely get ignored

			i = i+1
			puts i
			curr_el = getElementInOrdering(i, ordering)
		end
		return children
	end

	def changeParent(child, parent)
		if child.is_a?(Node) #if its a node, modify the relation so its parent is the new_node
			relation = child.parent_relationships.first #hierarchy relationship should always be first
			relation.parent_id = parent.id
			relation.save
			parent.child_relationships << relation
		elsif child.is_a?(Note) #if its a note, change its node_id to the current node's, fix the prev_parents combination
			prev_parent = Node.find(child.node_id)
			child.node_id = parent.id
			parent.add_note_to_combined(child)
			prev_parent.combine_notes()
			
			child.save
			parent.save
			prev_parent.save
		end
	end

	def getElementInOrdering(index, ordering)
		if index >= ordering.length
			return nil
		end

		if ordering[index].model == "node"
			curr_el = Node.find(ordering[index].id)
		else
			curr_el = Note.find(ordering[index].id)
		end #this should be a function. have to do it over and over
		return curr_el
	end

	#find a way to avoid doing this every time, preferably using instance variables
	def populateOrdering
		ordering = Array.new
		self.nodes.each do |node|
			ordering.push(ObjectPlace.new("node", node.id))
			#puts "node" + node.id.to_s
			node.notes.each do |note|
				ordering.push(ObjectPlace.new("note", note.id))
				#puts "note" + note.id.to_s
			end
		end
		return ordering
	end


	def parseText
		Node.destroy_all(work_id: self.id)
		stack = Array.new
		
		markup.each_line do |line|
			#puts "\n--------\n"
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
			firstChar = line.match(/[ ,\t]*(.)/).captures.first

			#if a new node should be made
			if firstChar == '<'
				new_node = Node.new
				buildNode(new_node, line)
				new_node.save

				#get the parent.
				depth = new_node.depth

				newNodeDepth = NodeDepth.new(new_node.id, depth)
				
				if depth == 0 #if it's a base element
					stack.push(newNodeDepth)
				else
					currNodeDepth = stack.pop
					while depth <= currNodeDepth.depth do #while you're less deep, therefore it aint yo momma 
						currNodeDepth = stack.pop
					end #at this point, @currNodeDepth is the nearest element that's not as deep as the new one, it's parent
					parentNode = Node.find(currNodeDepth.node_idnum)

					#creates the link, and the sets the parent and child relation
					relation = Link.new(child_id: new_node.id, parent_id: parentNode.id, work_id: self.id)
					relation.save
					new_node.parent_relationships << relation
					parentNode.child_relationships << relation

					stack.push(currNodeDepth)#push the parent back in, in case it has siblings
					stack.push(newNodeDepth)#push self in, in case it has children

					#@new_node.parent_relationships.build(child_id: @new_node.id, parent_id:@parentNode.id)
					#@new_node.parents << @parentNode
					#@parent_node.child=
					#make this nodes id into the parents child.
					#make the child's parent the parentNode's id.
				end
				new_node.save

			#if it's a note
			elsif firstChar == '-'
				new_note = Note.new()
				buildNote(new_note, line)

				#this is a bug. it just gets attached to the previous node without regard for depth
				parentNodeDepth = stack.pop
				parentNode = Node.find(parentNodeDepth.node_idnum)
				stack.push(parentNodeDepth)
				
				new_note.node_id = parentNode.id
				parentNode.add_note_to_combined(new_note)
				new_note.save
				
			#for special chars
			elsif firstChar == ':'
				puts "colontown!"

			else
				#this currently does the same as the dash
				new_note = Note.new()
				buildNote(new_note, line)
				
				puts "#000@" + new_note.body
				parentNodeDepth = stack.pop
				parentNode = Node.find(parentNodeDepth.node_idnum)
				stack.push(parentNodeDepth)
				
				new_note.node_id = parentNode.id
				parentNode.add_note_to_combined(new_note)
				new_note.save
			end
		end
	end

	#builds a note, getting its parent, attaching its data, and then returns the note
	def buildNote(note, text)
		content = text.match(/-(.*)/).captures.first
		note.body = content

		whitespace = text.match(/(.*)-/).captures.first
		note.depth = (whitespace.length)/3 #+2?

		return note
	end

	#builds a node (including type, title, category) and returns it
	def buildNode(node, text)
		withinBrackets = text.match(/<.*>/).to_s

		#get type, convert it to a constant, and makes a new node of that type
		type = withinBrackets.match(/<(.*)\./).captures.first
		type[0] = type[0].capitalize
		if @@types.include? type
			type = (type + "Node")
		else
			type = "BasicNode"
		end
		
		node.type = type

		#get the category string, use it to pull a category id
		category = withinBrackets.match(/\.(.*)>/).captures.first
		category_id = 0
		Category.all.each do |cat|
			if (category.downcase) == (cat.name).downcase
				category_id = (Category.where("name = ?", cat.name).first).id
			end
		end
		if category_id == 0
			category_id = (Category.where(name: "Uncategorized").first).id
		end
		node.category_id = category_id
		#puts category_id

		title = text.match(/>(.*)/).captures.first
		title = title.strip	

		whitespace = text.match(/(.*)</).captures.first
		node.depth = (whitespace.length)/3 #+2?
		#puts title
		node.title = title
		node.work_id = self.id
		return node
	end

end