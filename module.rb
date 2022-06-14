def text_availability_fuel (azs)
  text_cash = []
  text_cash << 'PULLS 95' if azs.m95_cash
  text_cash << 'A-95' if azs.a95_cash
  text_cash << 'PULLS ДП' if azs.mdp_cash
  text_cash << 'ДП' if azs.dp_cash
  text_cash << 'ГАЗ' if azs.dp_cash
  text_talon = []
  text_talon << 'PULLS 95' if azs.m95_talon
  text_talon << 'A-95' if azs.a95_talon
  text_talon << 'PULLS ДП' if azs.mdp_talon
  text_talon << 'ДП' if azs.dp_talon
  text_talon << 'ГАЗ' if azs.dp_talon

  text = "#{azs.brand} #{azs.adresa}\n"

  if text_cash.any? || text_talon.any?
    string_cash =  "За готівку і банківські карти доступно: #{text_cash.join(', ')}\n"
    text += string_cash if text_cash.any?
    string_talon =  "З паливною картою і талонами доступно: #{text_talon.join(', ')}\n"
    text += string_talon if text_talon.any?
  else 
    text += "Паливо відсутнє."
  end

  text
end
