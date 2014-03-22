# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :node do
    title ""
    category factory: :category
    work factory: :work
    combined_notes ""
    type ""
    depth 1
  end
end
