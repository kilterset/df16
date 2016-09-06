namespace :load_data do
  task contact: :environment do
    require 'csv'
    data_path = Rails.root.join('lib', 'data', 'contact_data_10k.csv')
    CSV.foreach(data_path, { headers: true }) do |row|
      name = row.field('name')
      interests = row.field('interests')
      Contact.create!({
        name: name,
        interests: interests
      })
    end

    puts "Contacts imported. Count=#{Contact.count}"
  end
end
