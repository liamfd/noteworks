# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link_collection do
    node factory: :node
  end
end
