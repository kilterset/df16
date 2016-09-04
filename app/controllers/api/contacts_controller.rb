module Api
  class ContactsController < ApplicationController

    def index
      contacts = Contact.all

      render json: { data: contacts.map(&method(:serialize_contact)) }
    end

    def show
      contact = Contact.find(params[:id])

      render json: { data: serialize_contact(contact) }
    end

    private

    def serialize_contact(contact)
      {
        name: contact.name,
        photo_url: contact.photo_url,
        interests: contact.interests
      }
    end
  end
end
