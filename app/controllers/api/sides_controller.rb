class Api::SidesController < ApplicationController
  def index
    @sides = Side.all
    render json: {
      :data => @sides.as_json(except: [:id, :created_at]),
      :success => true,
      :total => @sides.length,
      :version_number => "3.0" 
    }
  end

  def show
    @side = Side.find_by(code: params[:code])

    render json: {
      :data => @side.nil? ? [] : [@side.as_json(except: [:id, :created_at])],
      :success => !@side.nil?,
      :total => @side.nil? ? 0 : 1,
      :version_number => "3.0" 
    }
  end
end
