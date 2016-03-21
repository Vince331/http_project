class Notes
  def initialize(notes)
    @notes = notes
  end

  def match(matchers)
    result = @notes
    matchers.select do |elem|
      result = result.select do |x|
        x.upcase.include? elem.upcase
      end
    end
    result
  end
end
