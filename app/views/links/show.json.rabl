#attributes :id => :id.to_s(), :parent_id => :source, :child_id => :target

#node(:id) { |link| link.id.to_s() }
#node(:source) { |link| link.parent_id.to_s() }
#node(:target) { |link| link.child_id.to_s() }


#child :links, :root => :edges, :object_root => :datas, unless: lambda{|l| l.child_id == nil} do
#	node(:id) { |link| link.id.to_s() }
#	node(:source) { |link| link.parent_id.to_s() }
#	node(:target) { |link| link.child_id.to_s() }
#end

#
object @links
child @links, :root => :edges, :object_root => :datas, unless: lambda{|l| l.child_id == nil} do |link|
	node(:id) { id.to_s() }
	node(:source) { parent_id.to_s() }
	node(:target) { child_id.to_s() }
end


#node do |link|
#    if (link.parent_id != nil)
 #   	node(:id) { |link| link.id.to_s() }
#		node(:source) { |link| link.parent_id.to_s() }
#		node(:target) { |link| link.child_id.to_s() }
#	end
#end