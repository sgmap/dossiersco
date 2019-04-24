# frozen_string_literal: true

require 'test_helper'

class AgentPiecesJointesControllerTest < ActionDispatch::IntegrationTest

  def test_upload_un_fichier_puis_affiche_un_compte_rendu_du_contenu
    admin = Fabricate(:admin)
    identification_agent(admin)
    piece_attendue = Fabricate(:piece_attendue)
    eleve = Fabricate(:dossier_eleve).eleve

    piece_jointe = fixture_file_upload('files/sample.png', 'image/png')
    post agent_pieces_jointes_url, params: { piece_jointe: {fichier: piece_jointe, piece_attendue_id: piece_attendue.id}, eleve_id: eleve.identifiant}

    assert_redirected_to "/agent/eleve/#{eleve.identifiant}#dossier"
  end

end