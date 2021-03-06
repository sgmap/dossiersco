# frozen_string_literal: true

require "test_helper"

class AccueilControllerTest < ActionDispatch::IntegrationTest

  def test_connexion
    get "/connexion"
    assert response.parsed_body.include? "Inscription"
  end

  def test_entree_succes_eleve_non_inscrit
    dossier = Fabricate(:dossier_eleve, resp_legal: [Fabricate(:resp_legal)])

    post "/identification", params: {
      identifiant: dossier.identifiant,
      annee: dossier.annee_de_naissance,
      mois: dossier.mois_de_naissance,
      jour: dossier.jour_de_naissance
    }
    follow_redirect!
    assert response.body.include? "Pour réinscrire votre enfant"
  end

  def _test_normalise_ine
    # en attendant de place cette methode en dehors du controller
    assert_equal "070803070AJ", normalise_alphanum(" %! 070803070aj _+ ")
  end

  def test_entree_succes_eleve_1
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal], etape_la_plus_avancee: "accueil")
    post "/identification", params: {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    follow_redirect!
    assert response.body.include? "Pour réinscrire votre enfant"
  end

  def test_entree_mauvaise_date
    dossier = Fabricate(:dossier_eleve, resp_legal: [Fabricate(:resp_legal)])

    post "/identification", params: {
      identifiant: dossier.identifiant,
      annee: dossier.annee_de_naissance,
      mois: dossier.mois_de_naissance,
      jour: (dossier.jour_de_naissance.to_i + 1.days).to_s
    }

    follow_redirect!
    assert response.body.include?(html_escape("Nous n'avons pas reconnu ces identifiants, merci de les vérifier."))
  end

  def test_entree_mauvais_identifiant_et_date
    resp_legal = Fabricate(:resp_legal)
    dossier = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    params = {
      identifiant: "MAUVAISIDENTIFIANT",
      annee: dossier.annee_de_naissance,
      mois: dossier.mois_de_naissance,
      jour: dossier.jour_de_naissance
    }
    post "/identification", params: params

    follow_redirect!
    message_erreur = "Nous n'avons pas reconnu ces identifiants, merci de les vérifier."
    assert response.body.include?(html_escape(message_erreur))
  end

  def test_nom_college_accueil
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    identification(dossier_eleve)
    follow_redirect!
    doc = Nokogiri::HTML(response.parsed_body)
    assert_equal "Collège #{dossier_eleve.etablissement.nom}", doc.xpath("//div//h1/text()").to_s
  end

  def identification(dossier)
    params = {
      identifiant: dossier.identifiant,
      annee: dossier.annee_de_naissance,
      mois: dossier.mois_de_naissance,
      jour: dossier.jour_de_naissance
    }
    post "/identification", params: params
  end

  def test_modification_lieu_naiss_eleve
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    identification(dossier_eleve)

    post "/eleve", params: { dossier_eleve: { ville_naiss: "Beziers", prenom: "Edith" } }
    get "/eleve"
    assert response.parsed_body.include? "Edith"
    assert response.parsed_body.include? "Beziers"
  end

  def test_modifie_une_information_de_eleve_preserve_les_autres_informations
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])

    params = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    post "/identification", params: params
    post "/eleve", params: { dossier_eleve: { prenom: "Edith" } }
    get "/eleve"
    assert response.parsed_body.include? "Edith"
  end

  def test_accueil_et_inscription
    post "/identification", params: { identifiant: "1", annee: "1995", mois: "11", jour: "19" }
    follow_redirect!
    assert response.parsed_body.include? "inscription"
  end

  test "ramène parent à dernière étape incomplète" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])

    post "/identification", params: {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    post "/eleve", params: { dossier_eleve: { prenom: dossier_eleve.prenom }, Espagnol: true, Latin: true }
    get "/famille"

    post "/identification", params: {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    follow_redirect!

    doc = Nokogiri::HTML(response.parsed_body)
    assert_equal "Responsable légal", doc.xpath("/html/body/main/section/form/h2[1]").text
  end

  test "une famille remplit l'etape administration" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])
    regime_sortie = Fabricate(:regime_sortie, etablissement: dossier_eleve.etablissement)
    Fabricate(:regime_sortie, etablissement: dossier_eleve.etablissement)

    post "/identification", params: {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    get "/administration"
    post "/administration", params: {
      demi_pensionnaire: true,
      regime_sortie: regime_sortie.id,
      renseignements_medicaux: true,
      droit_image_photo: false
    }
    get "/administration"

    dossier = DossierEleve.find(dossier_eleve.id)
    parsed_body = response.body.gsub(/\s/, "")
    assert parsed_body.include? "id=\"regime_sortie_#{regime_sortie.id}\" checked".gsub(/\s/, "")
    assert parsed_body.include? "id='renseignements_medicaux' checked".gsub(/\s/, "")
    assert_equal false, dossier.autorise_photo_de_classe
  end

  test "ramene à la dernire etape visitée plutot que l'etape la plus avancée" do
    resp_legal = Fabricate(:resp_legal)
    dossier_eleve = Fabricate(:dossier_eleve, resp_legal: [resp_legal])

    params = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    params_famille = { "dossier_eleve[resp_legal_attributes][0][nom]": "test",
                       "dossier_eleve[resp_legal_attributes][0][id]": resp_legal.id }

    post "/identification", params: params
    post "/famille", params: params_famille
    get "/eleve"
    post "/deconnexion"
    params = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    post "/identification", params: params
    follow_redirect!
    assert response.parsed_body.include? html_escape("Identité de l'élève")
  end

  test "une famille choisi un régime d'autorisation de sortie" do
    etablissement = Fabricate(:etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    params_identification = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    regime_sortie = Fabricate(:regime_sortie)
    Fabricate(:regime_sortie)

    params = { regime_sortie: regime_sortie.id }

    post "/identification", params: params_identification
    post "/administration", params: params

    assert_equal regime_sortie, DossierEleve.find(dossier_eleve.id).regime_sortie
  end

  test "une famille préfère continuer à utiliser DossierSCO l'année prochaine" do
    etablissement = Fabricate(:etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    params_identification = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }

    params = { continuer_dossiersco: true }

    assert_nil DossierEleve.find(dossier_eleve.id).continuer_dossiersco

    post "/identification", params: params_identification
    post "/continuer_dossiersco", params: params

    assert_equal true, DossierEleve.find(dossier_eleve.id).continuer_dossiersco
  end

  test "Une pièce jointe non validée peut être modifiée" do
    etablissement = Fabricate(:etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    params_identification = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    post "/identification", params: params_identification

    piece_attendue = Fabricate(:piece_attendue, etablissement: etablissement)
    Fabricate(:piece_jointe, piece_attendue: piece_attendue, dossier_eleve: dossier_eleve, etat: "soumis")
    get pieces_a_joindre_path

    assert response.parsed_body.include? 'id="piece_jointe_fichiers"'
  end

  test "Une pièce jointe validée ne peut pas être modifiée" do
    etablissement = Fabricate(:etablissement)
    dossier_eleve = Fabricate(:dossier_eleve, etablissement: etablissement)
    params_identification = {
      identifiant: dossier_eleve.identifiant,
      annee: dossier_eleve.annee_de_naissance,
      mois: dossier_eleve.mois_de_naissance,
      jour: dossier_eleve.jour_de_naissance
    }
    post "/identification", params: params_identification

    piece_attendue = Fabricate(:piece_attendue, etablissement: etablissement)
    Fabricate(:piece_jointe, piece_attendue: piece_attendue, dossier_eleve: dossier_eleve, etat: "valide")
    get pieces_a_joindre_path

    assert_not response.parsed_body.include? 'id="piece_jointe_fichiers"'
  end

end
