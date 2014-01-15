object @work => :elements

child :nodes, :root => :nodes, :object_root => :datas do
	node(:id) { |node| node.id.to_s() }
	node(:title) { |node| node.title }
end

child :links, :root => :edges, :object_root => :datas do
	node(:source) { |link| link.parent_id.to_s() }
	node(:target) { |link| link.child_id.to_s() }
end