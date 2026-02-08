FactoryBot.define do
  factory :purchase_item do
    association :company
    association :purchase
    association :inventory
    status { %w[none before completed].sample }
    scheduled_date { Date.current + rand(0..30) }
    completed_date { status == "completed" ? Date.current + rand(0..30) : nil }
    quantity { rand(1..100) }
  end
end
