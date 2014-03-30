object @work

child :nodes, :root => :nodes, :object_root => :datas do
	node(:id) { |node| node.id.to_s() }
	node(:title) { |node| node.title }
	node(:notes) { |node| node.combined_notes }
	node(:color) { |node| node.category.color }
end

#child :valid_links => "edges", object_root: "datas" do
#	node(:id) { |link| link.id.to_s() }
#	node(:source) { |link| link.child_id.to_s() }
#	node(:target) { |link| link.parent_id.to_s() }
#end

child :links, :root => :edges, :object_root => :datas do
	node(:id) { |link| link.id.to_s() }
	node(:source) { |link| link.child_id.to_s() }
	node(:target) { |link| link.parent_id.to_s() }
end

#child :links, unless: lambda{|l| l.child_id == nil || l.parent_id == nil}, :root => :edges, :object_root => :datas do
#	node(:id) { |link| link.id.to_s() }
#	node(:source) { |link| link.parent_id.to_s() }
#	node(:target) { |link| link.child_id.to_s() }
#end

#child :links, :root => :edges, :object_root => :datas do
#	node(:id, unless: lambda{|l| l.child_id == nil || l.parent_id == nil} ) { |link| link.id.to_s() }
#	node(:source, unless: lambda{|l| l.child_id == nil || l.parent_id == nil}) { |link| link.parent_id.to_s() }
#	node(:target, unless: lambda{|l| l.child_id == nil || l.parent_id == nil}) { |link| link.child_id.to_s() }
#end

#child :links, :root => :edges, :object_root => :datas do
#	if root_object.link.child_id == nil
#		node(:id) { |link| link.id.to_s() }
#		node(:source) { |link| link.parent_id.to_s() }
#		node(:target) { |link| link.child_id.to_s() }
#	end
#end