require 'rails_helper'

RSpec.describe 'viewing contact list', type: :feature, js: true do

  let!(:contact) {
    Contact.create!(
      name: 'bjorn tester',
      interests: 'pizza chips'
    )
  }

  let!(:contact_2) {
    Contact.create!(
      name: 'bob tester',
      interests: 'fishing pies'
    )
  }

  before do
    visit '/'
  end

  it 'displays a list of contacts' do
    expect(page).to have_content('Interested.io')

    expect(page).to have_content('bjorn tester')
    expect(page).to have_content('bob tester')

    ['pizza', 'chips', 'fishing', 'pies'].each do |interest|
      expect(page).to have_content(interest)
    end
  end

  it 'allows the list to be filtered' do
    expect(page).to have_content('bjorn tester')

    fill_in 'Filter interests:', with: 'pies'

    expect(page).to_not have_content('bjorn tester')
    expect(page).to have_content('bob tester')
  end
end
