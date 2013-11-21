json.array!(@nodes) do |node|
  json.extract! node, :title, :category_id, :work_id
  json.url node_url(node, format: :json)
end
