FactoryBot.define do
  factory :inventory do
    association :company
    quantity { rand(100..10_000) }
  end
end
