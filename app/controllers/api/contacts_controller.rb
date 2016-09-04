module Api
  class ContactsController < ApplicationController

    def index
      contacts = Contact.all

      if params[:interests].present?
        contacts = contacts.with_interests(params[:interests].split(','))
      end

      render json: { data: contacts.map(&method(:serialize_contact)) }
    end

    def show
      contact = Contact.find(params[:id])

      render json: { data: serialize_contact(contact) }
    end

    def update
      contact = Contact.find(params[:id])

      contact.update_attributes(contact_params)

      render json: { data: serialize_contact(contact) }
    end


    private

    def contact_params
      params.permit(:name, :photo_url, :interests)
    end

    def serialize_contact(contact)
      {
        id: contact.to_param,
        name: contact.name,
        photo_url: contact.photo_url,
        interests: contact.interests
      }
    end
  end
end
