class Work < ActiveRecord::Base
	belongs_to :group

	has_many :nodes, dependent: :destroy
	has_many :links, dependent: :destroy

	has_many :categories, dependent: :destroy

	ObjectPlace = Struct.new(:model, :id)
	NodeDepth = Struct.new(:node_idnum, :depth)

	@@types = [ "Basic",
         "Comparison",
         "Definition",
         "Example",
         "Key",
         "Media"
	]

	before_save :before_save_checker

	#bottom, private
  	def before_save_checker 
   		#if markup_changed?
   		#	parse_text
   		#end
   	#fix the infinite loop, then you can have this back
	end


	#parser shit
	def modify_element(line_number, line_content)
		from_insert = {}
		from_remove = {}
		to_modify = {}

		first_char = getTextFromRegexp(line_content, /[ ,\t]*(.)/)
		ordering = get_ordering

		ordering_el = ordering[line_number]
		curr_el = get_element_in_ordering(line_number, ordering);

		#bug if it goes from node to note, or anything else
		if first_char == '<' && ordering_el.model == "node" && curr_el.is_a?(Node)

			from_remove = remove_element(line_number, false)
			from_insert = insert_element(line_number, line_content, curr_el)

			#consolidates these into modify in insert
			if from_remove[:remove_nodes].first[:id] == from_insert[:add_nodes].first[:id]
				from_insert[:modify_nodes].append(from_insert[:add_nodes].first)
				from_insert[:add_nodes] = []
				from_remove[:remove_nodes] = []
			end

				#WHILE I SHOULD BE DOING THIS WITH THE EDGES, ADD/REMOVE IS THE SAME,
				#AND IDEALLY THEY WILL BE UNNECESSARY WHEN THE JS IS PROPER, AS THE NODE
				#WILL REMAIN ON MODIFY, EDGES CAN BE LEFT ALONE
				#if from_insert[:add_edges] == from_remove[:remove_edges]
				#	from_insert[:modify_edges] = from_insert[:add_edges]
				#	from_insert[:add_edges] = []
				#	from_remove[:remove_edges] = []
				#end
				#from_insert[:add_edges].zip(from_remove[:remove_edges]).each do |add_edge, rem_edge|
				#	if ((add_edge[:source] == rem_edge[:source]) && (add_edge[:target] == rem_edge[:target]))
				#		mod_edges << add_edge
				#	end
				#end

 		#if you have a note and are modding it
		elsif first_char == '-' && ordering_el.model == "note" && curr_el.is_a?(Note)
			from_remove = remove_element(line_number, false)
			from_insert = insert_element(line_number, line_content, curr_el)
		
		#if it's not the same or not formatted right, you want to get rid of what's there 
		#and insert whatever's appropriate
		else 
			from_remove = remove_element(line_number, true)
			from_insert = insert_element(line_number, line_content)
		end

		#to_modify = format_hash_for_AJAX(from_insert, from_remove)
		to_modify = merge_two_hashes(from_insert, from_remove)

		#return node
		return uniqify_arrays_in_hash(to_modify, :id)
	end

	#to be called from the AJAX, takes insertNewElement's response and formats it
	def add_new_element(lines_number, lines_content)
		new_element_hash = {modify_nodes: [], modify_edges: [], remove_edges: [], add_edges: []}
		lines_number.zip(lines_content).each do |number, content|
			new_element_hash = new_element_hash.merge(insert_element(number, content))
		end
		#return new_element_hash
		return uniqify_arrays_in_hash(new_element_hash, :id)

	end

	#to be called from the AJAX, takes remove_element's response and formats it
	def delete_element(lines_number)
		deleted_element_hash = {modify_nodes: [], modify_edges: [], remove_edges: [], add_edges: []}

		lines_number.each do |number|
			deleted_element_hash = deleted_element_hash.merge(remove_element(number))
		end
		#return deleted_element_hash
		return uniqify_arrays_in_hash(deleted_element_hash, :id)
	end

	#insert a new element, into the markup, ordering, and relations
	def insert_element(line_number, line_content, in_element=nil)
		to_modify = {modify_nodes: [], add_nodes: [], remove_nodes: [], modify_edges: [], remove_edges: [], add_edges: []}

		ordering = get_ordering
		first_char = getTextFromRegexp(line_content, /[ ,\t]*(.)/)

		#update the markup
		markup_lines = get_markup_lines
		markup_lines.insert(line_number, line_content);
		set_markup(markup_lines);


		if first_char == "<"
			#shouldn't need this
			if in_element != nil && in_element.is_a?(Node) #only use the in_el if it's not nil and the right type
				new_node = in_element
			else #to be safe, generally do a new one.
				new_node = Node.new
			end
			build_node(new_node, line_content)
			new_node.save

			#update the ordering
			ordering.insert(line_number, ObjectPlace.new("node", new_node.id))
			set_order(ordering)

			#FIND PARENT
			if new_node.depth != 0 #if it's not a base element, give it a parent
				parent_node = find_element_parent(new_node.depth, line_number, ordering)
				if parent_node != nil #only give it a parent if it actually has one
					relation = Link.new(child_id: new_node.id, parent_id: parent_node.id, work_id: self.id)
					relation.save
				end
			#else
			#	relation = Link.new(child_id: new_node.id, parent_id: nil, work_id:self.id) #empty initial relationship
			end

			owner_id = nil
			remove_edges = []

			#FIND CHILDREN, ADOPT THEM (FROM EXISTING PARENT, THE WORD IS KIDNAP)
			children = find_element_children(line_number, new_node.depth, ordering)
			children.each do |child|
				#removes the old edges
				if child[:node].is_a?(Node) #add the old edges to be removed, since that connection is broken
					old_parent_edge = child[:node].parent_relationships.first
					if old_parent_edge != nil
						remove_edges.append(old_parent_edge.to_cytoscape_hash)
						#remove_edges.append({ id: old_parent_edge.id, source: old_parent_edge.parent_id.to_s, target: old_parent_edge.child_id.to_s })
					end

				elsif child[:node].is_a?(Note)
					owner_id = child[:node].node_id
				end

				change_parent(child[:node], new_node)
				#updates the now changed parents if necessary
				if owner_id != nil #if there's a real parent at the end, modify it in the graph
					to_modify[:modify_nodes].append(Node.find(owner_id).to_cytoscape_hash[:node])
				
				elsif child[:node].is_a?(LinkCollection)
					#if it's a link collection, remove all those links, gonna reassign
					child[:node].links.each do |link|
						to_modify[:modify_edges].append(link.to_cytoscape_hash)
						#remove_edges.append({ id: link.id, source: link.parent_id.to_s, target: link.child_id.to_s })
					end
				end
				owner_id = nil #resets it to make the above check false for non-nodes
			end

			to_modify[:add_nodes].append(new_node.to_cytoscape_hash[:node])
			to_modify[:add_edges] = new_node.to_cytoscape_hash[:edges]
			to_modify[:remove_edges] = remove_edges

			return to_modify

		elsif first_char == '-'
			if in_element != nil && in_element.is_a?(Note) #only use the in_el if it's not nil and the right type
				new_note = in_element
			else
				new_note = Note.new
			end

			build_note(new_note, line_content)
			new_note.save
			ordering.insert(line_number, ObjectPlace.new("note", new_note.id))
			set_order(ordering)

			#FIND PARENT
			parent_node = find_element_parent(new_note.depth, line_number, ordering)
			if parent_node != nil #if it has a parent, set it. ignore otherwise
				new_note.node_id = parent_node.id
				new_note.save
				parent_node.combine_notes
			#else
			#	new_note.node_id = nil
			#	new_note.save
			else
				new_note.save
			end
			if parent_node != nil #if it actually has a parent
				to_modify[:modify_nodes].append(parent_node.to_cytoscape_hash[:node])
				to_modify[:modify_edges] = parent_node.to_cytoscape_hash[:edges]
			end
			#to_modify[:remove_edges] = []
			return to_modify
	

		elsif first_char == ':'
			#build link collection
			#link_coll = self.link_collections.build
			whitespace = getTextFromRegexp(line_content, /(.*):/)
			link_coll_depth = (whitespace.length)/3 #+2?

			ordering.insert(line_number, ObjectPlace.new("lcoll", nil))
			set_order(ordering)
			parent_node = find_element_parent(link_coll_depth, line_number, ordering)

			if parent_node != nil #only create these if it does have that parent
				link_coll = parent_node.link_collections.build
				#link_coll.node = parent_node
				#parent_node.link_colls << link_coll
				
				link_names = getTextFromRegexp(line_content, /:(.*)/)
				link_coll.set_links(link_names)

				link_coll.depth = link_coll_depth
				link_coll.save

				if link_coll.links != nil && link_coll.links.any?
					link_coll.links.each do |link|
						to_modify[:add_edges].append(link.to_cytoscape_hash)
					end
				end
			
				#update id in ordering
				ordering[line_number].id = link_coll.id
				set_order(ordering)
			end

			return to_modify

		else
			ordering.insert(line_number, ObjectPlace.new("null", nil))
			set_order(ordering)
			return {}
		end
	end


	def remove_element(line_number, del_obj=true)
		to_modify = {modify_nodes: [], add_nodes: [], remove_nodes: [], modify_edges: [], remove_edges: [], add_edges: []}

		ordering = get_ordering
		el = get_element_in_ordering(line_number, ordering)
		if (el.is_a?(Node))
			to_modify[:remove_nodes].append(el.to_cytoscape_hash[:node])
			to_modify[:remove_edges] = el.to_cytoscape_hash[:edges]

			#find elements children, remove element, then redo the order
			children = find_element_children(line_number, el.depth, ordering)

			#update the ordering
			ordering.delete_at(line_number)
			set_order(ordering)
			
			#update the markup
			markup_lines = get_markup_lines
			markup_lines.delete_at(line_number);
			set_markup(markup_lines);

			#for each child, find their new parent according to the ordering, update the elements
			children.each do |child|

				new_parent = find_element_parent(child[:node].depth, child[:index], ordering)
				
				#this does a lot of things, including redoing the notes, but only happens if it's a node getting deleted?
				change_parent(child[:node], new_parent)
				if child[:node].is_a?(Node) #add the old edges to be removed, since that connection is broken
					new_parent_edge = child[:node].parent_relationships.first
					if (new_parent_edge != nil)
						to_modify[:add_edges].append({ id: new_parent_edge.id, source: new_parent_edge.parent_id.to_s, target: new_parent_edge.child_id.to_s })
					end
				
				elsif child[:node].is_a?(Note) && new_parent != nil #if there's a real parent at the end, modify it in the graph
					to_modify[:modify_nodes].append(new_parent.to_cytoscape_hash[:node])
				
				elsif child[:node].is_a?(LinkCollection) && new_parent != nil #if adopted, modify the edges
					child[:node].links.each do |link|
						to_modify[:modify_edges].append(link.to_cytoscape_hash)
					end
					#to_modify[:modify_edges].append(child[:node].links.to_cytoscape_hash)
				
				elsif child[:node].is_a?(LinkCollection) && new_parent == nil #if orphaned, ditch those edges
					child[:node].links.each do |link|
						to_modify[:remove_edges].append(link.to_cytoscape_hash)
					end
					#to_modify[:remove_edges].append(child[:node].links.to_cytoscape_hash)
				

				end
			end

			el.parent_relationships.delete_all
			if del_obj #delete unless explicitly told not to (when it's called from modify)
				el.delete
			end

		elsif (el.is_a?(Note))
			#update the ordering
			ordering.delete_at(line_number)
			set_order(ordering)
		
			#update the markup
			markup_lines = get_markup_lines
			markup_lines.delete_at(line_number);
			set_markup(markup_lines);

			#save the owning node of this note, delete the note, then redo the owner's notes
			owner = el.node
			if del_obj #delete unless explicitly told not to (when it's called from modify)
				el.delete
			end

			owner.combine_notes
			to_modify[:modify_nodes].append(owner.to_cytoscape_hash[:node])
			to_modify[:modify_edges] = owner.to_cytoscape_hash[:edges]
		
		elsif (el.is_a?(LinkCollection))
			#binding.pry
			#update the ordering
			ordering.delete_at(line_number)
			set_order(ordering)
		
			#update the markup
			markup_lines = get_markup_lines
			markup_lines.delete_at(line_number);
			set_markup(markup_lines);

			#links = el.links
			if el.links != nil && el.links.any?
				el.links.each do |link|
					to_modify[:remove_edges].append(link.to_cytoscape_hash)
				end
			end
			#el.links.destroy_all#inform the nodes of this
			#binding.pry
			if del_obj #delete unless explicitly told not to (when it's called from modify)
				el.destroy #destroys its children as well, hence destroy
			end


		else #if it's not formatted right
			#remove_node = {}
			#remove_edges = []

			#update the ordering
			ordering.delete_at(line_number)
			set_order(ordering)
			
			#update the markup
			markup_lines = get_markup_lines
			markup_lines.delete_at(line_number);
			set_markup(markup_lines);
			return {}
		end

		return to_modify
	end

	# works for node and note, both have depth
	def find_element_parent(el_depth, index, ordering)
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
	def find_element_children(index, el_depth, ordering)
		children = Array.new
		i = index + 1
		curr_el = get_element_in_ordering(i, ordering)
		while (curr_el == "null") #ignore nil elements
			i = i+1
			curr_el = get_element_in_ordering(i, ordering)
		end

		if curr_el.is_a?(Node)
			curr_child_depth = curr_el.depth
		else #if it's a note, it can't have children, so arbitrary big depth that'll get rest on the first node
			curr_child_depth = 100000
		end

		while (curr_el != nil && el_depth < curr_el.depth) #until you find something of equal or lesser depth
			#basically, include it if it's nested deeper (therefore in this loop,) but don't go into children of what you find)
			if curr_el.depth <= curr_child_depth && curr_el.is_a?(Node)
				node_and_index = { node: curr_el, index: i}
				children.push(node_and_index)
				curr_child_depth = curr_el.depth
			elsif curr_el.depth <= curr_child_depth && (curr_el.is_a?(Note) || curr_el.is_a?(LinkCollection))
				node_and_index = { node: curr_el, index: i}
				children.push(node_and_index)
				curr_child_depth = 100000 
			end
			#if there's an indented note after some nodes, it will likely get ignored

			i = i+1
			curr_el = get_element_in_ordering(i, ordering)
			while (curr_el == "null") #ignore nil elements
				i = i+1
				curr_el = get_element_in_ordering(i, ordering)
			end
		end
		return children
	end

	def change_parent(child, parent)
		if child.is_a?(Node) #if its a node, modify the relation so its parent is the new_node

			relation = child.parent_relationships.first #hierarchy relationship should always be first
			if (parent != nil) #if there is a parent for it

				if relation != nil #if it already has a parent relation. should be .any?
					relation.parent_id = parent.id
					relation.save
					child.save
					parent.save
				else #if it doesn't have a parent already
					relation = Link.new(child_id: child.id, parent_id: parent.id, work_id: self.id)
					relation.save
					child.save
				end
				#parent.child_relationships << relation

			else #if it doesn't have a new parent to be assigned
				if (relation != nil) #if it exists, delete it
					relation.delete
				end #if it doesn't exist and doesn't need to, do nothing
			end
			
			#relation = child.parent_relationships.first #hierarchy relationship should always be first
			#if (parent != nil)
			#	relation.parent_id = parent.id
			#	relation.save
			#	#parent.child_relationships << relation
			#else
			#	relation.parent_id = nil
			#	relation.save
			#end
			

		elsif child.is_a?(Note)
			prev_parent_id = child.node_id
			if (parent != nil) #if it has a new parent parent already
				child.node_id = parent.id
				child.save
				parent.notes << child
				parent.save
				parent.combine_notes
			else #if it doesn't have a parent, don't set it to anything
				child.node_id = nil
				child.save			
			end

			#update the notes of the other node, if it exists
			if Node.exists?(prev_parent_id) #automatically false if nil, so if it has no prev_parent, works even if it thinks it does
				prev_parent = Node.find(prev_parent_id)
				prev_parent.combine_notes()
				prev_parent.save
			end
		
		elsif child.is_a?(LinkCollection)
			if (parent != nil) #if it has a new parent
				child.links.each do |link| #reassign its links to that parent
					link.change_parent(parent)
				end
			else #if a new parent wasn't found for it
				child.links.each do |link| #reassign its links to nil
					link.change_parent(nil)
				end
			end
		end
	end


	def set_markup(markup_lines)
		m = markup_lines.join("\r\n") #join with \r\n
		self.update_attribute :markup, m
	end

	def get_markup_lines
		return markup.split(/\r\n|[\r\n]/) #match \r\n if present, if not either works
	end


	#takes an array ordering, converts it to the order string and saves
	def set_order(ordering)
		o = ""
		ordering.each do |obj_place|
			o << (obj_place.model + "_" + obj_place.id.to_s + "///,")
		end
		self.update_attribute :order, o
	end
	
	#returns ordering array (elements of type ObjectPlace), based on the self.order string
	def get_ordering
		order_a = self.order.split("///,") #o is the array of strings
		ordering = []
		order_a.each do |o|
			model = getTextFromRegexp(o, /([a-z]*)_/) #gets everything before underscore (only letters)
			id = getTextFromRegexp(o, /_([0-9]*)/) #gets everything after underscore (only digits)
			ordering.push(ObjectPlace.new(model, id))
		end
		return ordering
	end

	def get_element_in_ordering(index, ordering)
		if index >= ordering.length
			return nil
		end

		if ordering[index].model == "node"
			curr_el = Node.find(ordering[index].id)
		elsif ordering[index].model == "note"
			curr_el = Note.find(ordering[index].id)
		elsif ordering[index].model == "lcoll"
			curr_el = LinkCollection.find(ordering[index].id)

		elsif ordering[index].model == "null"
			curr_el = "null"
		end
		return curr_el
	end

	def print_ordering(ordering)
		ordering.each do |item|
			if item.model == "node"
				node = Node.find(item.id)
				puts "<" + node.depth.to_s + node.title
			elsif item.model == "note"
				note = Note.find(item.id)
				puts "-" + note.depth.to_s + note.body
			end
		end
	end

	def parse_text
		Node.destroy_all(work_id: self.id)
		Link.destroy_all(work_id: self.id)

		stack = Array.new
		o = []
		markup.each_line do |line|
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
		
			first_char = getTextFromRegexp(line, /[ ,\t]*(.)/)
		
			#if a new node should be made
			if first_char == '<'
				new_node = Node.new
				build_node(new_node, line)
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
					if parentNode.id == new_node.id #if it didn't find any parent
						parent_id = nil
					else
						parent_id = parentNode.id
					end

					#creates the link, and the sets the parent and child relation
					relation = Link.new(child_id: new_node.id, parent_id: parent_id, work_id: self.id)
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
				o.push(ObjectPlace.new("node", new_node.id))

			#if it's a note
			elsif first_char == '-'
				new_note = Note.new()
				build_note(new_note, line)

				#this is a bug. it just gets attached to the previous node without regard for depth
				parentNodeDepth = stack.pop
				parentNode = Node.find(parentNodeDepth.node_idnum)
				stack.push(parentNodeDepth)
				
				new_note.node_id = parentNode.id
				parentNode.add_note_to_combined(new_note)
				new_note.save
				o.push(ObjectPlace.new("note", new_note.id))				
			#for special chars
			elsif first_char == ':'

				#ordering.insert(line_number, ObjectPlace.new("lcoll", nil))
				#set_order(ordering)
				#parent_node = find_element_parent(link_coll_depth, line_number, ordering)

				#this is a bug. it just gets attached to the previous node without regard for depth
				parent_node_depth = stack.pop
				parent_node = Node.find(parent_node_depth.node_idnum)
				stack.push(parent_node_depth)

				whitespace = getTextFromRegexp(line, /(.*):/)
				link_coll_depth = (whitespace.length)/3 #+2?

				if parent_node != nil
					link_coll = parent_node.link_collections.build
					#link_coll.node = parent_node
					#parent_node.link_colls << link_coll
					
					link_names = getTextFromRegexp(line, /:(.*)/)
					link_coll.set_links(link_names)

					link_coll.depth = link_coll_depth
					#binding.pry
					link_coll.save
					#update id in ordering
				end
				o.push(ObjectPlace.new("lcoll", link_coll.id))
			else
				o.push(ObjectPlace.new("null", nil))
			end
		end

		#should fix this so I can get rid of populate_ordering, only works here because things are produced in order, can do it as I go
		#o = populate_ordering
		set_order(o)
	end

	#builds a note, getting its parent, attaching its data, and then returns the note
	def build_note(note, text)
		content = getTextFromRegexp(text, /-(.*)/)
		#content = text.match(/-(.*)/).captures.first
		note.body = content

		whitespace = getTextFromRegexp(text, /(.*)-/)
		#whitespace = text.match(/(.*)-/).captures.first
		note.depth = (whitespace.length)/3 #+2?

		return note
	end

	#builds a node with category, title, and returns it
	def build_node(node, text)
		node.type = :BasicNode

		whitespace = text.partition(".").first
		pure_text = text.partition(".").last
		node.depth = (whitespace.length)/3 #+2?

		#get the category string, use it to pull a category id
		if pure_text.include?(",") #split by the comma if there is one
			category_name = pure_text.partition(",").first
			title = pure_text.partition(",").last
		else #default to splitting by the first whitespace
			category_name = pure_text.partition(" ").first
			title = pure_text.partition(" ").last
		end

		#need to make these only the categories that belong to the user
		category = Category.find_by name: category_name.downcase
		binding.pry
		if category == nil
			category = Category.find_by name: :uncategorized
		end
		node.category = category
	#	category_id = 0
	#	Category.all.each do |cat|
	#		if (category.downcase) == (cat.name).downcase
	#			category = Category.where("name = ?", cat.name).first
	#		end
	#	end
	#	if category_id == 0
	#		category_id = (Category.where(name: "Uncategorized").first).id
	#	end
	#	node.category_id = category_id
		
		#title = getTextFromRegexp(text, /,(.*)/)
		title = title.strip	
		
		node.title = title
		node.work_id = self.id
		return node
	end

	#builds a node (including type, title, category) and returns it
	def old_build_node(node, text)
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

	#fills ordering according to stored nodes and notes. OUTDATED, KEEPING FOR PARSETEXT, USE get_ordering
	#this only works if the node ids line up to the order, so not if any inserted
	def populate_ordering
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


	#takes a string and a regexp, returns the result or nothing if no result
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

	#takes in a hash of arrays, returns a version that has all repeated values removed (last one remains)
	def uniqify_arrays_in_hash(hash, sub_key)
		#iterates over each of the top level values in the hash
		new_hash = {}
		hash.map do |key,value|
			#using the sub key, removes all but the last added value
			new_hash[key] = value.reverse.uniq {|sub_value| sub_value[sub_key]}
		end
		return new_hash
	end

	#merges two hashes of arrays
	def merge_two_hashes(h1, h2)
		h1.merge(h2) do |key, v1, v2|
		  v1 + v2
		end
	end
end