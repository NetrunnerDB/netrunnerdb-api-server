class Api::FactionsController < ApplicationController
  def index
    @factions = Faction.all

    render json: {
      :data => @factions.as_json(except: [:id, :created_at]),
      :success => true,
      :total => @factions.length,
      :version_number => "3.0" 
    }
  end

  def show
    @faction = Faction.find_by(code: params[:code])

    render json: {
      :data => @faction.nil? ? [] : [@faction.as_json(except: [:id, :created_at])],
      :success => !@faction.nil?,
      :total => @faction.nil? ? 0 : 1,
      :version_number => "3.0" 
    }
  end
end
