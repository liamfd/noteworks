object @work => :elements

child :nodes, :root => :nodes, :object_root => :datas do
	attributes :id, :title
end

child :links, :root => :edges, :object_root => :datas do
	attribute :parent_id => :source
	attribute :child_id => :target
end