require 'theodor'

require 'minitest/autorun'
require 'rack/test'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_landing_page_redirects
    get '/'
    assert_equal 302, last_response.status
  end

  def test_all_lists
    get '/lists'
    assert_equal 200, last_response.status
  end
end
