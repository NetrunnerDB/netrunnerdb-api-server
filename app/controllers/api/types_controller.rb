class Api::TypesController < ApplicationController
  def index
    @card_types = CardType.all
    render json: {
      :data => @card_types.as_json(except: [:id, :created_at]),
      :success => true,
      :total => @card_types.length,
      :version_number => "3.0" 
    }
  end

  def show
    @card_type = CardType.find_by(code: params[:code])

    render json: {
      :data => @card_type.nil? ? [] : [@card_type.as_json(except: [:id, :created_at])],
      :success => !@card_type.nil?,
      :total => @card_type.nil? ? 0 : 1,
      :version_number => "3.0" 
    }
  end
end
