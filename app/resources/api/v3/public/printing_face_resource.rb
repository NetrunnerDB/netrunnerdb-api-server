module API
  module V3
    module Public
      class Api::V3::Public::PrintingFaceResource < JSONAPI::Resource
        immutable

        attributes :flavor, :display_illustrators, :copy_quantity, :updated_at

        key_type :string

        def illustrator_ids
          @model.illustrators.map { |s| s.id }
        end

        has_one :printing
      end
    end
  end
end
