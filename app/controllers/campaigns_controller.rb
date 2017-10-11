class CampaignsController < ApplicationController

  def index
    @campaigns = Campaign.all
  end

  def show
    id = params[:id]
    @users = Campaign.find_by(id: id).users
  end

end
