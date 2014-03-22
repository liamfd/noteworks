# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do
    child factory: :node
    parent factory: :node
    work factory: :work
    link_collection nil
  end
end
