object @work => :elements
node(:markup) {@work.markup.to_s}

child :nodes, :root => :nodes, :object_root => :datas do
	attributes :id, :title
end

child :links, :root => :edges, :object_root => :datas do

	attributes :parent_id => :source, :child_id => :target
end

child @links do
	attributes :parent_id => :source, :child_id => :target
end