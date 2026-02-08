FactoryBot.define do
  factory :purchase do
    association :company
    sequence(:num) { |n| "P#{n.to_s.rjust(8, '0')}" }
  end
end
