require File.expand_path('../../../test_helper', __FILE__)

module Etsy
  class TestModel
    include Etsy::Model
  end

  class ModelTest < Test::Unit::TestCase

    def mock_empty_request(options = {})
      body = options.delete(:body) { '{}' }
      Request.expects(:new).with('', options).returns(stub(:get => stub(:body => body, :code => 200)))
    end

    context 'An instance of a Model' do

      should 'perform no requests if :limit is 0' do
        Request.expects(:new).never
        TestModel.get_all('', :limit => 0)
      end

      should 'perform only one request if :limit is less than 100' do
        mock_empty_request(:limit => 10, :offset => 0).once
        TestModel.get_all('', :limit => 10)
      end

      should 'perform only one request if :limit is equal to 100' do
        mock_empty_request(:limit => 100, :offset => 0).once
        TestModel.get_all('', :limit => 100)
      end

      should 'perform multiple requests if :limit is greater than 100' do
        mock_empty_request(:limit => 100, :offset => 0).once
        mock_empty_request(:limit => 50, :offset => 100).once

        TestModel.get_all('', :limit => 150)
      end

      should 'perform only one request if :limit is :all and count is less than 100' do
        mock_empty_request(:limit => 100, :offset => 0, :body => '{"count": 10}').once
        TestModel.get_all('', :limit => :all)
      end

      should 'perform only one request if :limit is :all and count is equal to 100' do
        mock_empty_request(:limit => 100, :offset => 0, :body => '{"count": 100}').once
        TestModel.get_all('', :limit => :all)
      end

      should 'perform only one request if :limit is :all and :offset is greater than count' do
        mock_empty_request(:limit => 100, :offset => 40, :body => '{"count": 25}').once
        TestModel.get_all('', :limit => :all, :offset => 40)
      end

      should 'perform multiple requests if :limit is :all and count is greater than 100' do
        body = '{"count": 210}'
        mock_empty_request(:limit => 100, :offset => 0, :body => body).once
        mock_empty_request(:limit => 100, :offset => 100, :body => body).once
        mock_empty_request(:limit => 10, :offset => 200, :body => body).once

        TestModel.get_all('', :limit => :all)
      end

      context 'performing a DELETE' do

        should 'construct a new Request object' do
          path, options = '/path', {}
          request_stub = stub(:delete => '')
          Request.expects(:new).with(path, options).returns(request_stub)
          TestModel.delete(path, options)
        end

        should 'delegate delete call to Request object' do
          path, options = '/path', {}
          delete_response = 'delete response'
          request_mock = mock { |m| m.expects(:delete).returns(delete_response) }
          Request.stubs(:new).returns(request_mock)
          TestModel.delete(path, options)
        end

        should 'construct a response object' do
          path, options = '/path', {}
          delete_response = 'delete response'
          request_stub = stub(:delete => delete_response)
          Request.stubs(:new).returns(request_stub)
          Response.expects(:new).with(delete_response)
          TestModel.delete(path, options)
        end

      end

    end
  end
end
