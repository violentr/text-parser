require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it {is_expected.to respond_to(:name)}
  it {is_expected.to respond_to(:users)}
end
