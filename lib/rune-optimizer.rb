require 'open-uri'
require 'nokogiri'
require_relative 'rune-page.rb'
require_relative 'rune-book.rb'

QUINT_SET_WEIGHT = 15
SMALL_RUNE_SET_WEIGHT = 10.8
MARSHAL_FILE_NAME = 'champion_role_list.marshal'

def available_runes

  runes_available = Hash.new

  runes_available['quints'] = ['Greater Quintessence of Attack Damage', 'Greater Quintessence of Ability Power', 'Greater Quintessence of Health', 'Greater Quintessence of Life Steal', 'Greater Quintessence of Movement Speed', 'Greater Quintessence of Armor']
  runes_available['marks'] = ['Greater Mark of Armor', 'Greater Mark of Attack Damage', 'Greater Mark of Magic Penetration', 'Greater Mark of Attack Speed']
  runes_available['seals'] = ['Greater Seal of Armor', 'Greater Seal of Health', 'Greater Seal of Scaling Health']
  runes_available['glyphs'] = ['Greater Glyph of Magic Resist', 'Greater Glyph of Scaling Magic Resist', 'Greater Glyph of Ability Power']

  runes_available
end

def viable_runes

  runes_viable = Array.new

  runes_viable = ['Greater Quintessence of Attack Speed', 'Greater Quintessence of Armor', 'Greater Quintessence of Armor Penetration', 'Greater Quintessence of Magic Penetration', 'Greater Mark of Attack Speed', 'Greater Mark of Armor Penetration', 'Greater Mark of Hybrid Penetration', 'Greater Mark of Critical Chance', 'Greater Mark of Ability Power', 'Greater Seal of Scaling Armor', 'Greater Seal of Scaling Health', 'Greater Seal of Attack Damage', 'Greater Seal of Ability Power', 'Greater Glyph of Scaling Ability Power', 'Greater Glyph of Scaling Cooldown Reduction', 'Greater Glyph of Cooldown Reduction', 'Greater Glyph of Armor', 'Greater Glyph of Attack Speed']

  runes_viable

end

def runes_on_LoG champion_roles
  runes_available = Hash.new
  runes_available['quints'] = Array.new
  runes_available['marks'] = Array.new
  runes_available['seals'] = Array.new
  runes_available['glyphs'] = Array.new
  champion_roles.each do |champion_role|
    champion_role[1].each do |rune_score|
      rune_category = find_rune_category_from_name(rune_score[0])
      unless(runes_available[rune_category].include?(rune_score[0]))
        runes_available[rune_category] << rune_score[0]
      end
    end
  end
  inferior = inferior_runes(runes_available, champion_roles)
  runes_available = subtract_runes(runes_available, inferior)
  runes_available
end

def subtract_runes(runes_available, inferiors)
  inferiors.each do |rune|
    category = find_rune_category_from_name(rune)
    if runes_available[category].include?(rune)
      runes_available[category].delete(rune)
    end
  end
  runes_available
end

def available_champions_roles

  # champion_role_list = [%w(garen top), %w(ryze top), %w(poppy top), %w(kayle top), %w(annie middle), %w(veigar middle), %w(ryze middle), %w(kayle middle), %w(nunu jungle), %w(masteryi jungle), %w(warwick jungle), %w(amumu jungle), %w(kayle jungle), %w(fiddlesticks jungle), %w(poppy jungle), %w(soraka support), %w(alistar support), %w(annie support), %w(janna support), %w(tristana adc), %w(sivir adc), %w(ashe adc)]

  champion_role_list = [%w(garen top), %w(ryze top), %w(poppy top), %w(kayle top), %w(annie middle), %w(veigar middle), %w(ryze middle), %w(kayle middle), %w(nunu jungle), %w(masteryi jungle), %w(warwick jungle), %w(amumu jungle), %w(kayle jungle), %w(fiddlesticks jungle), %w(poppy jungle), %w(soraka support), %w(alistar support), %w(annie support), %w(janna support), %w(tristana adc), %w(sivir adc), %w(ashe adc), %w(veigar support)]

  # scrape_LoG_for_champion_roles
end

def available_rune_book(rune_combinations = nil)

  pages = Array.new

  pages[0] = RunePage.new('Greater Quintessence of Movement Speed', 'Greater Mark of Attack Damage', 'Greater Seal of Scaling Health', 'Greater Glyph of Scaling Magic Resist')
  pages[1] = RunePage.new('Greater Quintessence of Health', 'Greater Mark of Armor', 'Greater Seal of Armor', 'Greater Glyph of Magic Resist')
  pages[2] = RunePage.new('Greater Quintessence of Life Steal', 'Greater Mark of Armor', 'Greater Seal of Scaling Health', 'Greater Glyph of Magic Resist')
  pages[3] = RunePage.new('Greater Quintessence of Ability Power', 'Greater Mark of Magic Penetration', 'Greater Seal of Scaling Health', 'Greater Glyph of Scaling Magic Resist')
  pages[4] = RunePage.new('Greater Quintessence of Movement Speed', 'Greater Mark of Attack Speed', 'Greater Seal of Armor', 'Greater Glyph of Scaling Magic Resist')
  pages[5] = RunePage.new('Greater Quintessence of Attack Damage', 'Greater Mark of Attack Damage', 'Greater Seal of Armor', 'Greater Glyph of Magic Resist')

  book = RuneBook.new(pages, available_champions_roles, rune_combinations)

  book
end

def scrape_LoG (champion_role_list)

  champion_roles = Hash.new

  champion_role_list.each do |champion_role|
    champion_roles[champion_role] = Hash.new(0)

    scraped_site = Nokogiri::parse(open("http://www.leagueofgraphs.com/champions/runes/#{champion_role.first}/#{champion_role.last}"))

    scraped_site.css('#mainContent .txt,.percentage').each_slice(7) do |element|
      champion_roles[champion_role][without_spaces(element[0].text)] = element[4].text.chomp('%').to_r
    end

    puts "Scraped site for #{champion_role}"
  end
  puts ''

  champion_roles
end

def without_spaces string
  string.lstrip.chomp(' ')
end

def champion_name_to_LoG_URL_name champion_name
  name = champion_name.tr("' .", '').downcase

  if(name == 'wukong')
    name = 'monkeyking'
  end

  name
end

def scrape_LoG_for_champion_roles
  champion_role_list = Array.new

  scraped_site = Nokogiri::parse(open("http://www.leagueofgraphs.com/champions/stats"))
  scraped_site.css('#mainContent .name,#mainContent i').each_slice(2) do |element|
    element[1].text.split(',').each do |role|
      role_without_spaces = without_spaces(role)
      champion_name = champion_name_to_LoG_URL_name(without_spaces(element[0].text))
      if (role_without_spaces == 'AD Carry')
        champion_role_list << [champion_name, 'adc']
      elsif (role_without_spaces == 'Mid')
        champion_role_list << [champion_name, 'middle']
      elsif (role_without_spaces == 'Jungler')
        champion_role_list << [champion_name, 'jungle']
      else
        champion_role_list << [champion_name, role_without_spaces.downcase]
      end
    end
  end

  champion_role_list
end

def find_rune_category_from_name(rune)
  second_word_of_rune_name = rune.split[1]
  if second_word_of_rune_name == 'Quintessence'
    return 'quints'
  else
    return second_word_of_rune_name.downcase + 's'
  end
end

def inferior_runes(runes_available, champion_roles, tolerance = 0)
  inferior_runes = Array.new
  %w(quints marks seals glyphs).each do |rune_type|
    runes_available[rune_type].each do |rune1|
      runes_available[rune_type].each do |rune2|
        unless rune1 == rune2
          if(rune_inferior_to?(rune1, rune2, champion_roles, 0))
            unless inferior_runes.include?(rune1)
              inferior_runes << rune1
            end
          end
        end
      end
    end
  end
  inferior_runes
end

def rune_inferior_to?(rune1, rune2, champion_roles, tolerance = 0)
  champion_roles.each do |champion_role|
    if(champion_role.last[rune1] > champion_role.last[rune2] + tolerance)
      return false
    end
  end
  return true
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

def find_best_book(rune_pages, rune_page_number, champion_role_list, rune_combinations)
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
      puts rune_book_champions.max_by{ |book| book.value_of_book }
      rune_books = Array.new
    end
  end
  rune_book_champions << rune_books.max_by{ |book| book.value_of_book }
  rune_book_champions.max_by{ |book| book.value_of_book }
end

def find_best_book_page_by_page(rune_pages, rune_page_number, champion_role_list, rune_combinations)
  pages = Array.new
  (1..rune_page_number).each do
    pages << rune_pages.first
  end
  best_books = Array.new
  best_books << RuneBook.new(pages, champion_role_list, rune_combinations)
  current_value = best_books.last.value_of_book
  new_value = best_books.last.value_of_book + 1
  until (new_value == current_value)
    current_value = best_books.last.value_of_book
    new_value = best_books.last.value_of_book
    (0..rune_page_number-1).each do |page_number|
      rune_pages.each do |page|
        new_pages = Array.new(best_books.last.pages)
        new_pages[page_number] = page
        new_rune_book = RuneBook.new(new_pages, champion_role_list, rune_combinations)
        if(best_books.last.value_of_book < new_rune_book.value_of_book)
          puts 'New Rune Book!'
          puts new_rune_book
          best_books << new_rune_book
          new_value = new_rune_book.value_of_book
        end
      end
    end
  end
  best_books.last
end

def combine_runes(runes_available, champion_role_list, champion_roles)

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
  [rune_pages, rune_combinations]
end

def run_optimizer(scrape, rune_page_number, free, rank_purchases)

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

  elsif rank_purchases
    runes_available = available_runes

    runes_viable = viable_runes

    purchases_books = Hash.new

    runes_viable.each do |rune|
      new_runes_available = Hash.new
      new_runes_available['quints'] = Array.new(runes_available['quints'])
      new_runes_available['marks'] = Array.new(runes_available['marks'])
      new_runes_available['seals'] = Array.new(runes_available['seals'])
      new_runes_available['glyphs'] = Array.new(runes_available['glyphs'])
      new_runes_available[find_rune_category_from_name(rune)] << rune

      combine_result = combine_runes(new_runes_available, champion_role_list, champion_roles)

      rune_pages = combine_result[0]
      rune_combinations = combine_result[1]

      purchases_books[rune] = find_best_book_page_by_page(rune_pages, rune_page_number, champion_role_list, rune_combinations)
    end

    combine_result = combine_runes(runes_available, champion_role_list, champion_roles)

    rune_pages = combine_result[0]
    rune_combinations = combine_result[1]

    purchases_books['no purchase'] = find_best_book_page_by_page(rune_pages, rune_page_number, champion_role_list, rune_combinations)
    purchases_books['rune_page'] = find_best_book_page_by_page(rune_pages, rune_page_number + 1, champion_role_list, rune_combinations)
    purchases_books['two_rune_pages'] = find_best_book_page_by_page(rune_pages, rune_page_number + 2, champion_role_list, rune_combinations)

    ranked_purchases_values = purchases_books.sort_by{ |k, v| v.value_of_book }

    ranked_purchases_values.each do |purchase_value|
      puts purchase_value.first
      puts purchase_value.last.value_of_book
    end
  else

    runes_available = available_runes

    combine_result = combine_runes(runes_available, champion_role_list, champion_roles)

    rune_pages = combine_result[0]
    rune_combinations = combine_result[1]

    puts find_best_book_page_by_page(rune_pages, rune_page_number, champion_role_list, rune_combinations)
  end
end
