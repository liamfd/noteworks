json.elements @work.id.to_s()

json.set! @work.nodes do |node|
	json.id  node.id.to_s()
end