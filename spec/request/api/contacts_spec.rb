require 'rails_helper'

RSpec.describe '/api/contacts', type: :request do
  DEFAULT_ATTRS = {
    name: 'bob tester',
    photo_url: 'http://localhost/photos/1',
    interests: 'pizza chips'
  }

  def create_contact!(attributes = {})
    Contact.create!(DEFAULT_ATTRS.merge(attributes))
  end

  let!(:contact) { create_contact! }

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
            id: contact.to_param,
            name: 'bob tester',
            photo_url: 'http://localhost/photos/1',
            interests: 'pizza chips'
          }
        ]
      )
    end

    context 'filtering by interests' do
      let!(:contact) {
        create_contact!(interests: 'pizza')
      }
      let!(:contact_2) {
        create_contact!(interests: 'pizza skiing')
      }
      let!(:contact_3) {
        create_contact!(interests: 'skiing')
      }
      let!(:contact_4) {
        create_contact!(interests: 'fishing')
      }

      it 'returns all the contacts with an interest in pizza' do
        get '/api/contacts?interests=pizza'

        expect(response).to have_http_status(200)

        expect(parsed_json[:data].map{|c| c[:interests]}.sort).to eql(
          [
            'pizza',
            'pizza skiing'
          ]
        )
      end

      it 'returns all the contacts with an interest in skiing' do
        get '/api/contacts?interests=skiing'

        expect(response).to have_http_status(200)

        expect(parsed_json[:data].map{|c| c[:interests]}.sort).to eql(
          [
            'pizza skiing',
            'skiing'
          ]
        )
      end

      it 'returns all the contacts with an interest in skiing or fishing' do
        get '/api/contacts?interests=skiing,fishing'

        expect(response).to have_http_status(200)

        expect(parsed_json[:data].map{|c| c[:interests]}.sort).to eql(
          [
            'fishing',
            'pizza skiing',
            'skiing'
          ]
        )
      end
    end
  end

  describe 'GET /{id}' do
    it 'returns the individual contact' do
      get "/api/contacts/#{contact.to_param}"

      expect(response).to have_http_status(200)

      expect(parsed_json).to eql(
        data: {
          id: contact.to_param,
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

      expect(parsed_json).to eql(data: req_data.merge(id: contact.to_param))

      get "/api/contacts/#{contact.to_param}"

      expect(parsed_json).to eql(data: req_data.merge(id: contact.to_param))
    end
  end
end
