class Api::SubtypesController < ApplicationController
  def index
    @subtypes = Subtype.all
    render json: {
      :data => @subtypes.as_json(except: [:id, :created_at]),
      :success => true,
      :total => @subtypes.length,
      :version_number => "3.0" 
    }
  end

  def show
    @subtype = Subtype.find_by(code: params[:code])

    render json: {
      :data => @subtype.nil? ? [] : [@subtype.as_json(except: [:id, :created_at])],
      :success => !@subtype.nil?,
      :total => @subtype.nil? ? 0 : 1,
      :version_number => "3.0" 
    }
  end
end
