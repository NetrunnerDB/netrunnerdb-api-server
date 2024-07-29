# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewResource, type: :resource do
  describe 'serialization' do
    let!(:review) { Review.find(1) }

    it 'works' do
      params[:filter] = { id: { eq: review.id } }
      render

      data = jsonapi_data[0]
      expect(data.id).to eq(review.id)
      expect(data.username).to eq(review.user_id)
      expect(data.votes).to eq(review.review_votes.length)
      expect(data.created_at).to eq(review.created_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.updated_at).to eq(review.updated_at.strftime('%Y-%m-%dT%H:%M:%S%:z'))
      expect(data.jsonapi_type).to eq('reviews')
    end
  end

  describe 'filtering' do
    let!(:review) { Review.find(1) }

    context 'with id' do
      before do
        params[:filter] = { id: { eq: review.id } }
      end

      it 'filters to id' do
        render
        expect(d.map(&:id)).to eq([review.id])
      end
    end

    context 'with card_id' do
      before do
        params[:filter] = { card_id: { eq: review.card_id } }
      end

      it 'filters on card_id' do
        render
        expect(d.map(&:id)).to eq([review.id])
      end
    end
  end

  describe 'sideloading' do
    def check_included_for_id(object_id, include_type, resource_type, sideloaded_id)
      params[:filter] = { id: { eq: object_id } }
      params[:include] = include_type
      render

      included = jsonapi_included[0]
      expect(included.jsonapi_type).to eq(resource_type)

      ids = []
      jsonapi_included.map { |i| ids << i.id.to_s }
      expect(ids).to include(sideloaded_id)
    end

    describe 'includes card' do
      let!(:endurance) { Card.find('endurance') }
      let!(:endurance_review) { Review.find(1) }

      it 'works' do
        check_included_for_id(endurance_review.id, 'card', 'cards', endurance.id)
      end
    end
  end
end
