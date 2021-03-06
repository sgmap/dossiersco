# frozen_string_literal: true

module Configuration
  class AgentsController < ApplicationController

    layout "configuration"

    before_action :identification_agent
    before_action :if_agent_is_admin, except: %i[edit update activation]

    def new
      @agent = Agent.new
    end

    def create
      @agent = Agent.new(agent_params)
      @agent.etablissement = @agent_connecte.etablissement
      service_agent = ServiceAgent.new(@agent)
      if service_agent.reset_mot_de_passe!
        @agent = service_agent.agent
        AgentMailer.invite_agent(@agent, @agent_connecte).deliver_now
        redirect_to configuration_agents_path, notice: t(".invitation_envoyee", email: @agent.email)
      else
        flash[:alert] = "L'email #{@agent.email} est déjà utilisé"
        render :new
      end
    end

    def index
      @agents = Agent.pour_etablissement(agent_connecte.etablissement)
    end

    def edit
      @agent = @agent_connecte
    end

    def update
      ancien_jeton = @agent_connecte.jeton
      @agent_connecte.jeton = nil
      if @agent_connecte.update(agent_params)
        session[:agent_email] = @agent_connecte.email
        redirect_to configuration_agents_path, notice: t("messages.compte_cree")
      else
        @agent = @agent_connecte
        @agent.jeton = ancien_jeton
        if @agent_connecte.jeton
          render :activation, layout: "connexion"
        else
          render :edit
        end
      end
    end

    def destroy
      @agent = Agent.find(params[:id])
      @agent.destroy
      redirect_to configuration_agents_path, notice: "L'agent a bien été supprimé"
    end

    def changer_etablissement
      @agent_connecte.update(etablissement_id: params[:etablissement])
      redirect_to agent_tableau_de_bord_path
    end

    def activation
      @agent = @agent_connecte
      render layout: "connexion"
    end

    private

    def agent_params
      params.require(:agent).permit(:prenom, :nom, :password, :etablissement_id, :admin, :email)
    end

  end
end
