require 'json'
require 'faraday'

require 'nokogiri'

def parsing_okko(list)
  link = 'http://176.117.190.22:9292'
  response = Faraday.get(link)
  data = JSON.parse(response.body)
  azs = {}

  data.each do |record|
    azs_id = record['attributes']['Cod_AZK']
    next unless list.include?(azs_id)
    azs.store(azs_id, {})
    azs[azs_id].store('m95_cash', false)
    azs[azs_id].store('m95_talon', false)
    azs[azs_id].store('a95_cash', false)
    azs[azs_id].store('a95_talon', false)
    azs[azs_id].store('dp_cash', false)
    azs[azs_id].store('dp_talon', false)
    azs[azs_id].store('mdp_cash', false)
    azs[azs_id].store('mdp_talon', false)
    azs[azs_id].store('gas_cash', false)
    azs[azs_id].store('gas_talon', false)

    azs[azs_id].store('brand', 'OKKO')
    azs[azs_id].store('adresa', record['attributes']['Adresa'])
    notification = record['attributes']['notification']
    html = Nokogiri::HTML(notification)

    if not(html.css('ol')[0].nil?)
      line = html.css('ol')[0].css('strong').text
      azs[azs_id].store('m95_cash', true) if line.include?('PULLS 95')
      azs[azs_id].store('a95_cash', true) if line.include?('А-95')
      azs[azs_id].store('mdp_cash', true) if line.include?('PULLS Diesel')
      azs[azs_id].store('dp_cash', true) if line.include?('ДП')
      azs[azs_id].store('gas_cash', true) if line.include?('ГАЗ')
    end

    if not(html.css('ol')[1].nil?)
      line = html.css('ol')[1].css('strong').text
      azs[azs_id].store('m95_talon', true) if line.include?('PULLS 95')
      azs[azs_id].store('a95_talon', true) if line.include?('А-95')
      azs[azs_id].store('mdp_talon', true) if line.include?('PULLS Diesel')
      azs[azs_id].store('dp_talon', true) if line.include?('ДП')
      azs[azs_id].store('gas_talon', true) if line.include?('ГАЗ')
    end
  end
  azs
end

def parsing_wog(list)
  link_base = 'https://api.wog.ua/fuel_stations/'
  azs = {}
  list.each do |azs_id|
    link = link_base + azs_id.to_s
    response = Faraday.get(link)

    data = JSON.parse(response.body)
    azs_id = data['data']['id']
    azs.store(azs_id, {})
    azs[azs_id].store('m95_cash', false)
    azs[azs_id].store('m95_talon', false)
    azs[azs_id].store('a95_cash', false)
    azs[azs_id].store('a95_talon', false)
    azs[azs_id].store('dp_cash', false)
    azs[azs_id].store('dp_talon', false)
    azs[azs_id].store('mdp_cash', false)
    azs[azs_id].store('mdp_talon', false)
    azs[azs_id].store('gas_cash', false)
    azs[azs_id].store('gas_talon', false)

    azs[azs_id].store('adresa', data['data']['name'])
    azs[azs_id].store('brand', 'WOG')
    data['data']['workDescription'].each_line do |line|
      case line[0,3]
      when 'М95'
        azs[azs_id].store('m95_cash', true) if line.include?('отівка')
        azs[azs_id].store('m95_talon', true) if line.include?('алон')
      when 'А95'
        azs[azs_id].store('a95_cash', true) if line.include?('отівка')
        azs[azs_id].store('a95_talon', true) if line.include?('алон')
      when 'ДП '
        azs[azs_id].store('dp_cash', true) if line.include?('отівка')
        azs[azs_id].store('dp_talon', true) if line.include?('алон')
      when 'МДП'
        azs[azs_id].store('mdp_cash', true) if line.include?('отівка')
        azs[azs_id].store('mdp_talon', true) if line.include?('алон')
      when 'ГАЗ'
        azs[azs_id].store('gas_cash', true) if line.include?('отівка')
        azs[azs_id].store('gas_talon', true) if line.include?('алон')
      end
    end
  end
  azs
end
