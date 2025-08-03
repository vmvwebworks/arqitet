json.extract! project, :id, :title, :description, :location, :year, :category, :user_id, :created_at, :updated_at
json.url project_url(project, format: :json)
