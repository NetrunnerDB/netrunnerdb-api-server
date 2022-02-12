class Api::FactionResource < JSONAPI::Resource
  primary_key :code
  attributes :code, :name, :is_mini, :updated_at
  key_type :string
end
