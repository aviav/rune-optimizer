require 'open-uri'
require 'nokogiri'
require_relative 'rune-page.rb'
require_relative 'rune-book.rb'

def run_optimizer(scrape, page_number)

  champion_roles = Hash.new

  runes_available = Hash.new

  runes_available['quints'] = ['Greater Quintessence of Attack Damage', 'Greater Quintessence of Ability Power', 'Greater Quintessence of Health', 'Greater Quintessence of Life Steal', 'Greater Quintessence of Movement Speed']
  runes_available['marks'] = ['Greater Mark of Armor', 'Greater Mark of Attack Damage', 'Greater Mark of Magic Penetration']
  runes_available['seals'] = ['Greater Seal of Armor']
  runes_available['glyphs'] = ['Greater Glyph of Magic Resist', 'Greater Glyph of Scaling Magic Resist', 'Greater Glyph of Ability Power']

  champion_role_list = [%w(garen top), %w(ryze top), %w(poppy top), %w(annie middle), %w(veigar middle), %w(nunu jungle), %w(masteryi jungle), %w(warwick jungle), %w(amumu jungle), %w(kayle jungle), %w(fiddlesticks jungle), %w(poppy jungle), %w(soraka support), %w(alistar support), %w(annie support), %w(tristana adc), %w(sivir adc), %w(ashe adc)]

  if (scrape)
    champion_role_list.each do |champion_role|
      champion_roles[champion_role] = Hash.new(0)

      scraped_site = Nokogiri::parse(open("http://www.leagueofgraphs.com/champions/runes/#{champion_role.first}/#{champion_role.last}"))

      scraped_site.css('#mainContent .txt,.percentage').each_slice(7) do |element|
        champion_roles[champion_role][element[0].text.lstrip.chomp(' ')] = element[4].text.chomp('%').to_r
      end

      puts "Scraped site for #{champion_role}"
    end

    File.open('champion_role_list.marshal', 'w') do |file|
      file.write(Marshal.dump(champion_roles))
    end
  else
    File.open('champion_role_list.marshal', 'r') do |file|
      champion_roles = Marshal.load(file.read)
    end
  end

  rune_combinations = Hash.new

  rune_page_number = page_number

  rune_pages = Array.new

  runes_available['quints'].each do |quint|
    rune_combinations[quint] = Hash.new
    runes_available['marks'].each do |mark|
      rune_combinations[quint][mark] = Hash.new
      runes_available['seals'].each do |seal|
        rune_combinations[quint][mark][seal] = Hash.new
        runes_available['glyphs'].each do |glyph|
          rune_pages << RunePage.new(quint, mark, seal, glyph)
          rune_combinations[quint][mark][seal][glyph] = Hash.new
          champion_role_list.each do |champion_role|
            rune_combinations[quint][mark][seal][glyph][champion_role] = 0
            rune_combinations[quint][mark][seal][glyph][champion_role] += 15.to_r * champion_roles[champion_role][quint]
            rune_combinations[quint][mark][seal][glyph][champion_role] += 10.8.to_r * champion_roles[champion_role][mark]
            rune_combinations[quint][mark][seal][glyph][champion_role] += 10.8.to_r * champion_roles[champion_role][seal]
            rune_combinations[quint][mark][seal][glyph][champion_role] += 10.8.to_r * champion_roles[champion_role][glyph]
          end
        end
      end
    end
  end

  rune_books = Array.new

  count = 0

  rune_pages.combination(rune_page_number).each do |rune_book|
    count += 1
    if count % 2500 == 0
      puts "#{count} of #{rune_pages.combination(rune_page_number).size} rune books created"
    end
    rune_books << RuneBook.new(rune_book, champion_role_list, rune_combinations)
  end

  puts rune_books.max_by{ |book| book.value_of_book }
end
