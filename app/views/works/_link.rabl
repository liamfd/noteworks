node(:id) { |link| link.id.to_s() }
node(:source) { |link| link.child_id.to_s() }
node(:target) { |link| link.parent_id.to_s() }