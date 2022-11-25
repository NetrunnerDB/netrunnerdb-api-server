module API
  module V3
    module Public
      class Api::V3::Public::IllustratorResource < JSONAPI::Resource
        immutable

        attributes :name, :num_printings, :updated_at
        key_type :string

        paginator :none

        has_many :printings, relation_name: :unified_printings
      end
    end
  end
end
