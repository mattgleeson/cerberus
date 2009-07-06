require File.dirname(__FILE__) + '/test_helper'

require 'cerberus/publisher/twitter'
require 'cerberus/manager'
require 'mock/manager'
require 'mock/twitter'

class TwitterPublisherTest < Test::Unit::TestCase
  def test_publisher
    options = Cerberus::Config.new(nil, :publisher => {:twitter => {:login => 'twittest', :password => 'twitpass'}}, :application_name => 'TestApp')
    build = DummyManager.new('last message', 'this is output', 1232, 'anatol')

    Cerberus::Publisher::Twitter.publish(build_status(false), build, options)

    statuses = Twitter::Client.statuses
    assert_equal 1, statuses.size
    assert_equal '[TestApp] Build still broken (1232)', statuses.first
  end
end
