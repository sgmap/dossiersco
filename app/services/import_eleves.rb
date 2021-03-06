# frozen_string_literal: true

class ImportEleves

  def perform(tache)
    file = File.read("#{Rails.root}/public/#{tache.fichier}")
    xml = Nokogiri::XML(file)

    return if xml.xpath("/BEE_ELEVES/PARAMETRES/UAJ").text != tache.etablissement.uai

    met_a_jour_eleves!(xml)
    met_a_jour_les_dossiers!(tache.etablissement)
  end

  def met_a_jour_eleves!(xml)
    xml.xpath("/BEE_ELEVES/DONNEES/ELEVES/ELEVE").each do |noeud|
      dossier = DossierEleve.find_by(identifiant: noeud.xpath("ID_NATIONAL").text)
      next unless dossier

      met_a_jour_commune_insee_naissance(dossier, noeud)
      met_a_jour_id_prv_ele(dossier, noeud)
      met_a_jour_prenoms_ele(dossier, noeud)
      met_a_jour_dossier(dossier, noeud)
    end
  end

  def met_a_jour_commune_insee_naissance(dossier, noeud)
    return if dossier.commune_insee_naissance.present?

    code_insee = extrait_le_code_insee_naissance(noeud)
    dossier&.update(
      commune_insee_naissance: code_insee,
      ville_naiss: Commune.new.du_code_insee(code_insee)
    )
  end

  def met_a_jour_id_prv_ele(dossier, noeud)
    dossier&.update(
      id_prv_ele: extrait_id_eleve(noeud)
    )
  end

  def met_a_jour_prenoms_ele(dossier, noeud)
    dossier&.update(prenom_2: extrait_prenom2(noeud)) unless dossier&.prenom_2.present?
    dossier&.update(prenom_3: extrait_prenom3(noeud)) unless dossier&.prenom_3.present?
  end

  def met_a_jour_dossier(dossier_eleve, noeud)
    dossier_eleve&.update(
      mef_an_dernier: extrait_le_code_mef(noeud),
      division_an_dernier: extrait_la_precedente_division(noeud),
      division: extrait_division_courante(noeud)
    )
  end

  def extrait_id_eleve(noeud)
    id_prv_ele = noeud.xpath("ID_PRV_ELE")&.text
    return nil if id_prv_ele.blank?

    id_prv_ele
  end

  def extrait_le_code_insee_naissance(noeud)
    noeud.xpath("CODE_COMMUNE_INSEE_NAISS").text
  end

  def extrait_le_code_mef(noeud)
    noeud.xpath("SCOLARITE_AN_DERNIER/CODE_MEF").text
  end

  def extrait_la_precedente_division(noeud)
    noeud.xpath("SCOLARITE_AN_DERNIER/CODE_STRUCTURE").text
  end

  def extrait_division_courante(noeud)
    id = noeud.attributes["ELEVE_ID"]
    noeud.xpath("/BEE_ELEVES/DONNEES/STRUCTURES/STRUCTURES_ELEVE[@ELEVE_ID='#{id}']/STRUCTURE[1]/CODE_STRUCTURE").text
  end

  def extrait_prenom2(noeud)
    noeud.xpath("PRENOM2").text
  end

  def extrait_prenom3(noeud)
    noeud.xpath("PRENOM3").text
  end

  def met_a_jour_les_dossiers!(etablissement)
    AnalyseurRetourSiecle.analyse_dossiers!(etablissement.dossier_eleve)
  end

end
