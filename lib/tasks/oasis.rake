require 'csv'
namespace :oasis do
  desc "Create initial batch of Flickr and Instagram profiles from CSV files"
  task :seed_profiles => :environment do
    CSV.foreach("#{Rails.root}/config/flickr_profiles.csv") do |row|
      flickr_profile = FlickrProfile.new(name: row[2], id: row[1], profile_type: row[0])
      flickr_profile.save and FlickrPhotosImporter.perform_async(flickr_profile.id, flickr_profile.profile_type)
    end
    CSV.foreach("#{Rails.root}/config/instagram_profiles.csv") do |row|
      instagram_profile = InstagramProfile.new(username: row[1], id: row[0])
      instagram_profile.save and InstagramPhotosImporter.perform_async(instagram_profile.id)
    end
  end

  desc "Get recent photos for existing Flickr and Instagram profiles"
  task :refresh => :environment do
    FlickrProfile.all.each do |flickr_profile|
      FlickrPhotosImporter.perform_async(flickr_profile.id, flickr_profile.profile_type, 1)
    end
    InstagramProfile.all.each do |instagram_profile|
      InstagramPhotosImporter.perform_async(instagram_profile.id, 1)
    end
  end
end