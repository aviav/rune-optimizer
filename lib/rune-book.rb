class RuneBook

  attr_reader :pages, :value_of_book, :champion_roles_pages

  def initialize(pages, champion_role_list, rune_combinations)
    @pages = pages
    @champion_roles_pages = Hash.new
    @value_of_book = value(champion_role_list, rune_combinations)
  end

  def value(champion_role_list, rune_combinations)
    book_value = 0
    champion_role_list.each do |champion_role|
      page_values = Hash.new
      @pages.each do |page|
        page_values[page.to_s] = rune_combinations[page.quint][page.mark][page.seal][page.glyph][champion_role]
      end
      max_element = page_values.max_by{ |k,v| v }
      book_value += max_element.last
      @champion_roles_pages[champion_role] = max_element.first
    end
    book_value/champion_role_list.size/47.4
  end

  def to_s
    string = ''
    @champion_roles_pages.each do |page|
      string += "#{page.first.first} #{page.first.last}\n"
      string += "#{page.last}\n\n"
    end
    string += "Value: #{value_of_book.to_f}"
  end
end
