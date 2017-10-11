require File.expand_path('../../config/environment', __FILE__)

module PopulateDb
  def self.start(records)
    puts "Populating db with Campaigns and Users"
    records["Campaign"].each do |campaign, hash|
      campaign = ::Campaign.create(name: campaign)
      hash["Choice"].each do |name, score|
        person = OpenStruct.new(choice: name, count: score)
        campaign.users.create(name: person.choice, count: person.count)
      end
    end
    puts "Populating db was compleated"
  end
end
