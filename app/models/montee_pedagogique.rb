class MonteePedagogique < ActiveRecord::Base
  belongs_to :mef_origine, class_name: 'Mef'
  belongs_to :mef_destination, class_name: 'Mef'
  belongs_to :option_pedagogique
  belongs_to :etablissement

  validate :unique

  def unique
    montee = MonteePedagogique.find_by(mef_destination: self.mef_destination, mef_origine: self.mef_origine,
                                       option_pedagogique: self.option_pedagogique, etablissement_id: self.etablissement_id)
    if montee.present? && montee.id != self.id
      errors.add(:montee_pedagogique, "existe déjà")
    end
  end
end