module Api
  class TeamsController < ApplicationController
    resource_description do
      short 'Teams'
      formats ['json']
      description <<-PRCDESC
        This resource allows for the management of providers in popHealth

        popHealth assumes that providers are in a hierarchy. This resource allows users
        to see the hierarchy of providers
      PRCDESC
    end
    include PaginationHelper
    include LogsHelper
    # load resource must be before authorize resource
    load_resource except: %w{index create new}
    authorize_resource
    respond_to :json
    before_action :authenticate_user!
    
    api :GET, '/teams'
    description <<-SDESC
      This will return the list of the current user's teams.
    SDESC
    def index
      log_api_call LogAction::VIEW, "View all teams"
      @teams = @current_user.teams
      validate_authorization!(@teams)
      render json: @teams
    end
    
    api :GET, '/teams/:id'
    param :id, String, :desc => "Team ID", :required => true
    description <<-SDESC
      This will return an individual team based on the given ID
    SDESC
    def show
      log_api_call LogAction::VIEW, "Show team"
      @team = Team.find(params[:id])
      validate_authorization!([@team])
      render json: @team.to_json 
    end
    
    api :GET, '/teams/team_providers/:id'
    param :id, String, :desc => "Team ID", :required => true
    description <<-SDESC
      This will return the list of providers for a given team based on the ID 
    SDESC
    def team_providers
      log_api_call LogAction::VIEW, "Get providers for team"
      @team = Team.find(params[:id])
      validate_authorization!([@team])
      providers = @team.providers.map {|id| Provider.find(id)}

      render json: providers
    end
    
    private
      def validate_authorization!(teams)
        teams.each do |team|
          authorize! :manage, team
        end
      end
  end
end
