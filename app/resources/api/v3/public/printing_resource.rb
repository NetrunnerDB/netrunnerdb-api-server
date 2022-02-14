module API
  module V3
    module Public
      class Api::V3::Public::PrintingResource < JSONAPI::Resource
        # TODO: add relationships in here.
        attributes :card_id, :card_set_id, :printed_text, :printed_uniqueness, :flavor, :illustrator, :position, :quantity, :date_release, :updated_at
        key_type :string
      end
    end
  end
end
