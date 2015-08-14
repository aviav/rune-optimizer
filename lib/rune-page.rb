class RunePage

  attr_reader :quint, :mark, :seal, :glyph

  def initialize(quint, mark, seal, glyph)
    @quint = quint
    @mark = mark
    @seal = seal
    @glyph = glyph
  end

  def to_s
    "#{quint}\n#{mark}\n#{seal}\n#{glyph}"
  end
end
