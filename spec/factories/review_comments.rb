FactoryBot.define do
  factory :review_comment do
    body { "MyText" }
    username { "MyString" }
    review { nil }
  end
end
