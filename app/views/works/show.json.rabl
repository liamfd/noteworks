object @work => :elements

child :nodes, :root => :nodes, :object_root => "data".pluralize do
	attributes :id, :title
end

child :links, :root => :edges, :object_root => :data do
	attribute :parent_id => :source
	attribute :child_id => :target
end