FactoryBot.define do
  factory :delivery do
    association :company
    sequence(:num) { |n| "D#{n.to_s.rjust(8, '0')}" }
  end
end
