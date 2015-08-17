require 'open-uri'
require 'nokogiri'
require 'ruby-progressbar'
require_relative 'rune-page.rb'
require_relative 'rune-book.rb'

QUINT_SET_WEIGHT = 15
SMALL_RUNE_SET_WEIGHT = 10.8
MARSHAL_FILE_NAME = 'champion_role_list.marshal'

def available_runes

  runes_available = Hash.new

  runes_available['quints'] = ['Greater Quintessence of Attack Damage', 'Greater Quintessence of Ability Power', 'Greater Quintessence of Health', 'Greater Quintessence of Life Steal', 'Greater Quintessence of Movement Speed']
  runes_available['marks'] = ['Greater Mark of Armor', 'Greater Mark of Attack Damage', 'Greater Mark of Magic Penetration']
  runes_available['seals'] = ['Greater Seal of Armor']
  runes_available['glyphs'] = ['Greater Glyph of Magic Resist', 'Greater Glyph of Scaling Magic Resist', 'Greater Glyph of Ability Power']

  runes_available
end

def available_champions_roles

  # champion_role_list = [%w(garen top), %w(ryze top), %w(poppy top), %w(annie middle), %w(veigar middle), %w(nunu jungle), %w(masteryi jungle), %w(warwick jungle), %w(amumu jungle), %w(kayle jungle), %w(fiddlesticks jungle), %w(poppy jungle), %w(soraka support), %w(alistar support), %w(annie support), %w(tristana adc), %w(sivir adc), %w(ashe adc)]

  champion_role_list = [%w(garen top), %w(ryze top), %w(poppy top), %w(annie middle), %w(veigar middle), %w(nunu jungle), %w(masteryi jungle), %w(warwick jungle), %w(amumu jungle), %w(kayle jungle), %w(fiddlesticks jungle), %w(poppy jungle), %w(soraka support), %w(alistar support), %w(annie support), %w(tristana adc), %w(sivir adc), %w(ashe adc), %w(gnar top), %w(leesin jungle), %w(shyvana jungle), %w(nocturne jungle), %w(leblanc middle), %w(xerath middle), %w(anivia middle), %w(kalista adc), %w(leona support)]
end

def available_rune_book(rune_combinations = nil)

  pages = Array.new

  pages[0] = RunePage.new('Greater Quintessence of Movement Speed', 'Greater Mark of Attack Damage', 'Greater Seal of Armor', 'Greater Glyph of Magic Resist')
  pages[1] = RunePage.new('Greater Quintessence of Movement Speed', 'Greater Mark of Armor', 'Greater Seal of Armor', 'Greater Glyph of Scaling Magic Resist')
  pages[2] = RunePage.new('Greater Quintessence of Movement Speed', 'Greater Mark of Magic Penetration', 'Greater Seal of Armor', 'Greater Glyph of Ability Power')
  pages[3] = RunePage.new('Greater Quintessence of Ability Power', 'Greater Mark of Magic Penetration', 'Greater Seal of Armor', 'Greater Glyph of Ability Power')
  pages[4] = RunePage.new('Greater Quintessence of Attack Damage', 'Greater Mark of Attack Damage', 'Greater Seal of Armor', 'Greater Glyph of Scaling Magic Resist')
  pages[5] = RunePage.new('Greater Quintessence of Life Steal', 'Greater Mark of Attack Damage', 'Greater Seal of Armor', 'Greater Glyph of Scaling Magic Resist')

  book = RuneBook.new(pages, available_champions_roles, rune_combinations)

  book
end

def scrape_LoG (champion_role_list)

  champion_roles = Hash.new

  champion_role_list.each do |champion_role|
    champion_roles[champion_role] = Hash.new(0)

    scraped_site = Nokogiri::parse(open("http://www.leagueofgraphs.com/champions/runes/#{champion_role.first}/#{champion_role.last}"))

    scraped_site.css('#mainContent .txt,.percentage').each_slice(7) do |element|
      champion_roles[champion_role][element[0].text.lstrip.chomp(' ')] = element[4].text.chomp('%').to_r
    end

    puts "Scraped site for #{champion_role}"
  end
  puts ''

  champion_roles
end

def save_champion_roles champion_roles

  File.open(MARSHAL_FILE_NAME, 'w') do |file|
    file.write(Marshal.dump(champion_roles))
  end
end

def load_champion_roles

  champion_roles = nil

  File.open(MARSHAL_FILE_NAME, 'r') do |file|
    champion_roles = Marshal.load(file.read)
  end

  champion_roles
end

def compute_combination_score(page, champion_role, champion_roles)
  combination_score = 0
  if(champion_roles[champion_role][page.quint].nonzero? and champion_roles[champion_role][page.mark].nonzero? and champion_roles[champion_role][page.seal].nonzero? and champion_roles[champion_role][page.glyph].nonzero?)
    combination_score += QUINT_SET_WEIGHT.to_r * champion_roles[champion_role][page.quint]
    combination_score += SMALL_RUNE_SET_WEIGHT.to_r * champion_roles[champion_role][page.mark]
    combination_score += SMALL_RUNE_SET_WEIGHT.to_r * champion_roles[champion_role][page.seal]
    combination_score += SMALL_RUNE_SET_WEIGHT.to_r * champion_roles[champion_role][page.glyph]
    return combination_score/(QUINT_SET_WEIGHT + 3 * SMALL_RUNE_SET_WEIGHT)
  end
  combination_score
end

def run_optimizer(scrape, rune_page_number, free)

  champion_roles = Hash.new

  champion_role_list = available_champions_roles

  if scrape
    champion_roles = scrape_LoG(champion_role_list)

    save_champion_roles champion_roles
  else
    champion_roles = load_champion_roles
  end

  if free
    book = available_rune_book

    rune_combinations = Hash.new

    book.pages.each do |page|
      rune_combinations[page] = Hash.new
    end

    champion_role_list.each do |champion_role|

      book.pages.each do |page|
        rune_combinations[page][champion_role] = compute_combination_score(page, champion_role, champion_roles)
      end
    end
    puts RuneBook.new(book.pages, champion_role_list, rune_combinations)
  else

    runes_available = available_runes

    rune_combinations = Hash.new

    rune_pages = Array.new

    runes_available['quints'].each do |quint|
      runes_available['marks'].each do |mark|
        runes_available['seals'].each do |seal|
          runes_available['glyphs'].each do |glyph|
            current_rune_page = RunePage.new(quint, mark, seal, glyph)
            rune_pages << current_rune_page
            rune_combinations[current_rune_page] = Hash.new
            champion_role_list.each do |champion_role|
              rune_combinations[current_rune_page][champion_role] = compute_combination_score(current_rune_page, champion_role, champion_roles)
            end
          end
        end
      end
    end

    rune_books = Array.new
    rune_book_champions = Array.new

    count = 0

    progress_options = {
      title: 'Trying rune books',
      total: rune_pages.combination(rune_page_number).size,
      format: '%t |%E | %B | %a'
    }

    progress = ProgressBar.create(progress_options)

    rune_pages.combination(rune_page_number).each do |rune_book|
      progress.increment
      count += 1
      rune_book = RuneBook.new(rune_book, champion_role_list, rune_combinations)
      if rune_book.value_of_book.nonzero?
        rune_books << rune_book
      end
      if count % 250000 == 0
        best_book = rune_books.max_by{ |book| book.value_of_book }
        rune_book_champions << best_book
        File.open('rune_books.marshal', 'w') do |file|
          file.write(Marshal.dump(rune_books))
        end
        rune_books = Array.new
      end
    end
    rune_book_champions << rune_books.max_by{ |book| book.value_of_book }
    puts rune_book_champions.max_by{ |book| book.value_of_book }
  end
end
