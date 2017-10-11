require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  describe '#index' do
    it 'should have success message' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  describe '#show' do
    it 'should have list of users' do
      campaign = Campaign.create(name: "campaign")
      %w(Leon Anthony Lilit).each do |name|
        campaign.users.create(name: name, count: 12)
      end
      get :show, params: {id: campaign.id}
      expect(response).to have_http_status(:success)
    end
  end
end
