require 'rails_helper'

RSpec.describe '/api/contacts', type: :request do

  let!(:contact) {
    Contact.create!(
      name: 'bob tester',
      photo_url: 'http://localhost/photos/1',
      interests: 'pizza chips'
    )
  }

  describe 'GET /' do
    it 'returns a 200' do
      get '/api/contacts'

      expect(response).to have_http_status(200)
    end

    it 'returns a list of contacts' do
      get '/api/contacts'

      expect(parsed_json).to eql(
        data: [
          {
            name: 'bob tester',
            photo_url: 'http://localhost/photos/1',
            interests: 'pizza chips'
          }
        ]
      )
    end
  end

  describe 'GET /{id}' do
    it 'returns the individual contact' do
      get "/api/contacts/#{contact.to_param}"

      expect(response).to have_http_status(200)

      expect(parsed_json).to eql(
        data: {
          name: 'bob tester',
          photo_url: 'http://localhost/photos/1',
          interests: 'pizza chips'
        }
      )
    end

    it 'returns 404 for unknown resources' do
      respond_without_detailed_exceptions do
        get "/api/contacts/pizza"
      end

      expect(response).to have_http_status(404)
    end
  end

  describe 'PATCH /{id}' do
    let(:req_data) {
      {
        name: 'bjorn tester',
        photo_url: 'http://locahost/other-photos/1',
        interests: 'nordic skiing'
      }
    }

    it 'allows the resource to be updated' do
      patch "/api/contacts/#{contact.to_param}", req_data.to_json, json_request_headers

      expect(response).to have_http_status(200)

      expect(parsed_json).to eql(
        data: req_data
      )
    end
  end
end
