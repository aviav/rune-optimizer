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
          page_values[page.to_s] = rune_combinations[page][champion_role]
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
    @champion_roles_pages.each do |page|
      string += "#{page.first.first} #{page.first.last}\n"
      string += "#{page.last.first}\n"
      string += "Page value for champion: #{page.last.last}\n\n"
    end
    string += "Book value: #{value_of_book}"
  end
end
