json.array!(@works) do |work|
  json.extract! work, :markup, :group_id, :name
  json.url work_url(work, format: :json)
end
