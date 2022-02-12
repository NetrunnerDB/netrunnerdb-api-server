class Api::CardSubtypeResource < JSONAPI::Resource
  model_name 'Subtype' 
  primary_key :code
  attributes :code, :name, :updated_at
  key_type :string
end
