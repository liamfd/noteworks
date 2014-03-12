object @work

child :nodes, :root => :nodes, :object_root => :datas do
	node(:id) { |node| node.id.to_s() }
	node(:title) { |node| node.title }
	node(:notes) { |node| node.combined_notes }
	node(:color) { |node| node.category.color }
end

child :links, :root => :edges, :object_root => :datas do
	node(:id) { |link| link.id.to_s() }
	node(:source) { |link| link.parent_id.to_s() }
	node(:target) { |link| link.child_id.to_s() }
end