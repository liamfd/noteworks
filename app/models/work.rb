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

	def toJSONOutput(node)
		output = '{"nodes":[{"data":{'
		output << '"id":"' + node.id.to_s + '",'
		output << '"title":"' + node.title + '",'
		output << '"combined_notes":"' + node.combined_notes + '",'
		output << '"color":"' + node.category.color + '"'
		output << '}}]}'
		out_JSON = JSON.parse(output)
		return out_JSON
	end

	#parser shit
	def modifyElement(line_number, line_content)
		first_char = getTextFromRegexp(line_content, /[ ,\t]*(.)/)
				
		if first_char == '<'
			deleteElement(line_number)
			node = insertNewElement(line_number, line_content)
			#return node
			return toJSONOutput(node)
		elsif first_char == '-'
			deleteElement(line_number)
			node = insertNewElement(line_number, line_content)
		#	return node
			return toJSONOutput(node)
		else	
			return toJSONOutput(self.nodes.first)
		end

		#ordering = getOrdering()
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
		ordering = getOrdering
		first_char = getTextFromRegexp(line_content, /[ ,\t]*(.)/)
		#first_char = ""
		#matched = line_content.match(/[ ,\t]*(.)/)
		#if matched != nil
		#	first_char = matched.captures.first
		#end


		if first_char == "<"
			new_node = Node.new
			buildNode(new_node, line_content)
			new_node.save
			ordering.insert(line_number, ObjectPlace.new("node", new_node.id))
			setOrder(ordering)

			#FIND PARENT
			if new_node.depth != 0 #if it's not a base element
				parent_node = findElParent(new_node.depth, line_number, ordering)
				if parent_node != nil
					relation = Link.new(child_id: new_node.id, parent_id: parent_node.id, work_id: self.id)
					relation.save
				#	new_node.parent_relationships << relation
				#	parent_node.child_relationships << relation
				else
					relation = Link.new(child_id: new_node.id, parent_id: nil, work_id: self.id)
					relation.save
				#	new_node.parent_relationships << relation
				end

			end

			#FIND CHILDREN
			children = findElChildren(line_number, new_node.depth, ordering)
			children.each do |child|
				changeParent(child[:node], new_node)
			end

			return new_node

		else
			new_note = Note.new
			buildNote(new_note, line_content)
			new_note.save
			ordering.insert(line_number, ObjectPlace.new("note", new_note.id))
			setOrder(ordering)

			#FIND PARENT
			parent_node = findElParent(new_note.depth, line_number, ordering)
			if parent_node != nil
				new_note.node_id = parent_node.id
				parent_node.add_note_to_combined(new_note)
				new_note.save
			else
				new_note.node_id = nil
				new_note.save
			end
			return parent_node
		end
	end

	def deleteElement(line_number)
		ordering = getOrdering
		el = getElementInOrdering(line_number, ordering)

		#find elements children, remove element, then have them find new parents
		children = findElChildren(line_number, el.depth, ordering)
		ordering.delete_at(line_number)
		setOrder(ordering)

		#for each child, find their new parent according to the ordering, update the elements
		children.each do |child|
			new_parent = findElParent(child[:node].depth, child[:index], ordering)
			changeParent(child[:node], new_parent)
		end

		if el.is_a?(Node)
			el.parent_relationships.delete_all
		end
		el.delete

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
				#this might solve the bug below curr_child_depth = 100000 
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
			if (parent != nil)
				relation.parent_id = parent.id
				relation.save
				#parent.child_relationships << relation
			else
				relation.parent_id = nil
				relation.save
			end
			
		elsif child.is_a?(Note)
			prev_parent_id = child.node_id
			if (parent != nil)
				child.node_id = parent.id
				child.save
				parent.add_note_to_combined(child)
				parent.save
			else
				child.node_id = nil
				child.save			
			end

			if prev_parent_id != nil #only make changes to the previous parent if there is one
				prev_parent = Node.find(prev_parent_id)
				prev_parent.combine_notes()
				prev_parent.save
			end
		end
	end

	#takes an array ordering, converts it to the order string and saves
	def setOrder(ordering)
		o = ""
		ordering.each do |obj_place|
			o << (obj_place.model + "_" + obj_place.id.to_s + "///,")
		end
		self.order = o
		self.save
	end

	#returns the order string, NOT THE ORDERING ARRAY
	def getOrder
		return self.order
	end

	#returns ordering array (elements of type ObjectPlace), based on the self.order string
	def getOrdering
		order_a = self.order.split("///,") #o is the array of strings
		ordering = []
		order_a.each do |o|
			model = getTextFromRegexp(o, /([a-z]*)_/) #gets everything before underscore (only letters)
			#model = o.match(/([a-z]*)_/).captures.first #gets everything before underscore (only letters)
			id = getTextFromRegexp(o, /_([0-9]*)/) #gets everything after underscore (only digits)
			#id = o.match(/_([0-9]*)/).captures.first.to_i #gets everything after underscore (only digits)
			ordering.push(ObjectPlace.new(model, id))
		end
		return ordering
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

	def printOrdering(ordering)
		ordering.each do |item|
			if item.model == "node"
				puts "< " + Node.find(item.id).title
			elsif item.model == "note"
				puts "- " + Note.find(item.id).body
			end
		end
	end

	def parseText
		Node.destroy_all(work_id: self.id)
		Link.destroy_all(work_id: self.id)

		stack = Array.new
		
		markup.each_line do |line|
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
		
			first_char = getTextFromRegexp(line, /[ ,\t]*(.)/)
		
			#if a new node should be made
			if first_char == '<'
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
			elsif first_char == '-'
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
			elsif first_char == ':'
				puts "colontown!"

			else
				#this currently does the same as the dash
				new_note = Note.new()
				buildNote(new_note, line)
				
				parentNodeDepth = stack.pop
				parentNode = Node.find(parentNodeDepth.node_idnum)
				stack.push(parentNodeDepth)
				
				new_note.node_id = parentNode.id
				parentNode.add_note_to_combined(new_note)
				new_note.save
			end
		end

		#should fix this so I can get rid of populateOrdering, only works here because things are produced in order, can do it as I go
		o = populateOrdering
		setOrder(o)
	end

	#builds a note, getting its parent, attaching its data, and then returns the note
	def buildNote(note, text)
		content = getTextFromRegexp(text, /-(.*)/)
		#content = text.match(/-(.*)/).captures.first
		note.body = content

		whitespace = getTextFromRegexp(text, /(.*)-/)
		#whitespace = text.match(/(.*)-/).captures.first
		note.depth = (whitespace.length)/3 #+2?

		return note
	end

	#builds a node (including type, title, category) and returns it
	def buildNode(node, text)
		withinBrackets = getTextFromRegexp(text, /(<.*>)/)
		#withinBrackets = text.match(/<.*>/).to_s
		
		#get type, convert it to a constant, and makes a new node of that type
		type = getTextFromRegexp(withinBrackets, /<(.*)\./)
		#type = withinBrackets.match(/<(.*)\./).captures.first
		
		type[0] = type[0].capitalize
		if @@types.include? type
			type = (type + "Node")
		else
			type = "BasicNode"
		end
		
		node.type = type

		#get the category string, use it to pull a category id
		category = getTextFromRegexp(withinBrackets, /\.(.*)>/)
		#category = withinBrackets.match(/\.(.*)>/).captures.first
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

		title = getTextFromRegexp(text, />(.*)/)
		#title = text.match(/>(.*)/).captures.first
		title = title.strip	

		whitespace = getTextFromRegexp(text, /(.*)</)
		#whitespace = text.match(/(.*)</).captures.first
		node.depth = (whitespace.length)/3 #+2?
		#puts title
		node.title = title
		node.work_id = self.id
		return node
	end

	#fills ordering according to stored nodes and notes. OUTDATED, KEEPING FOR PARSETEXT, USE getOrdering
	#this only works if the node ids line up to the order, so not if any inserted
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

end

def getTextFromRegexp(text, expression)
	wanted = ""
	if text != nil
		matched = text.match(expression)
		if matched != nil
			wanted = matched.captures.first
		end
	end
	return wanted
end