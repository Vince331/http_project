require 'notes'

class NotesTest < Minitest::Test
  def test_it_selects_notes_whose_descriptions_matches_an_argument_from_the_command_line
    line_1 = 'Is 1 less than 2    1 < 2  # => true'
    notes = Notes.new([line_1])
    assert_equal [line_1], notes.match(["less"])
  end

  def test_select_notes_whose_example_matches_an_argument_from_the_command_line
    line_1 = "Find out how big the array is    \[\"a\",\"b\"\].length \# \=> 2\n"
    notes = Notes.new([line_1])
    assert_equal [line_1], notes.match(["length"])
  end

  def test_matching_is_case_insensitive
    line_1 = "Add 1 to 2    1 \+ 2  \# \=> 3\n"
    notes = Notes.new([line_1])
    assert_equal [line_1], notes.match(["add"])
    assert_equal [line_1], notes.match(["Add"])
  end

  def test_it_treats_multiple_arguments_as_successive_filters
    line_1 = 'Find out how big the array is    ["a","b"].length # => 2'
    line_2 = 'Access an element in an array by its index    ["a","b","c"][0] # => "a"'
    notes = Notes.new([line_1])
    assert_equal [line_1], notes.match(["big"])

    notes = Notes.new([line_1, line_2])
    assert_equal [line_1, line_2], notes.match(["array"])
    assert_equal [line_1], notes.match(["array", "big"])
  end

  def test_it_selects_all_notes_by_default
    first_line = 'Is 1 less than 2    1 < 2  # => true'
    last_line = 'Find out how big the array is    ["a","b"].length # => 2'
    notes = Notes.new([first_line, last_line])
    assert_equal [first_line, last_line], notes.match([])
  end
end
