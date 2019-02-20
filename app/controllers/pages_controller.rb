class PagesController < ApplicationController

  def redirection_erreur
    if !get_eleve.nil?
      redirect_to accueil_path
    elsif !agent_connecté.nil?
      redirect_to agent_tableau_de_bord_path
    else
      redirect_to root_path
    end
  end

  def get_eleve
    @eleve ||= Eleve.find_by(identifiant: session[:identifiant])
  end

  def test_sentry
    identification_agent
    begin
      1 / 0
    rescue ZeroDivisionError => exception
      Raven.capture_exception(exception)
    end
    render plain: "L'exception a été normalement capturée par Sentry"
  end
end
