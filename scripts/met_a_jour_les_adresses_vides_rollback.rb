# frozen_string_literal: true

RespLegal.select { |d| d.adresse&.strip == "Inconnue" }.each do |d|
  d.update_attribute("adresse", "")
end
