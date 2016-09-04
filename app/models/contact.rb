class Contact < ActiveRecord::Base

  scope :with_interests, -> (interests) {
    sql = (['interests like ?']*interests.length).join(' OR ')
    where(*sql, *interests.map {|i| "%#{i}%" })
  }
end
