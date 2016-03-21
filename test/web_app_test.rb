require 'notes/app'

class WebAppTest < Minitest::Test
  def test_when_i_go_to_the_main_page_i_see_a_box_to_search
    env = {'PATH_INFO' => '/', 'QUERY_STRING' => []}
    response_code, headers, body = Notes::APP.call(env)
    assert_equal 200, response_code
    assert_equal 'text/html', headers['Content-Type']
    assert_match /form/, body.join
  end

  def test_if_you_type_a_search_it_returns_what_you_searched_for
    env = {'PATH_INFO' => '/', 'QUERY_STRING' => ["length"]}
    response_code, headers, body = Notes::APP.call(env)
    assert_equal 200, response_code
    assert_equal 'text/html', headers['Content-Type']
    assert_match "Find out how big the array is    \[\"a\",\"b\"\].length \# \=> 2", body.join
  end
end
