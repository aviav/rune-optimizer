class RuneBook

  attr_reader :pages, :value_of_book, :champion_roles_pages

  def initialize(pages, champion_role_list, rune_combinations = nil)
    @pages = pages
    @champion_roles_pages = Hash.new
    @value_of_book = value(champion_role_list, rune_combinations)
  end

  def value(champion_role_list, rune_combinations)
    book_value = 0
    champion_role_list.each do |champion_role|
      page_values = Hash.new(0)
      @pages.each do |page|
        if(rune_combinations)
          page_values[page] = rune_combinations[page][champion_role]
        end
      end
      max_element = page_values.max_by{ |k,v| v }
      if(max_element)
        book_value += max_element.last
        @champion_roles_pages[champion_role] = [max_element.first, max_element.last]
      end
    end
    book_value/champion_role_list.size
  end

  def to_s
    string = ''
    pages_champion_roles = Hash.new

    @pages.each do |page|
      pages_champion_roles[page] = Array.new
    end

    @champion_roles_pages.each do |page|
      pages_champion_roles[page.last.first] << [page.first.first, page.first.last, page.last.last]
    end

    pages_champion_roles.each_with_index do |page, index|
      string += "Rune Page #{index + 1}\n\n"
      string += "#{page.first}\n\n"

      page.last.each do |champion_role|
        string += "#{champion_role.last.to_f.round(1)}% win rate: #{champion_role.first} #{champion_role[1]}\n"
      end

      string += "\n"
    end

    string += "Book value: #{value_of_book.to_f.round(3)}"
  end
end
