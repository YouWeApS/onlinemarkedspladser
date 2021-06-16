# frozen_string_literal: true

require 'rails_helper'

class TestController < V1::ApplicationController
  def index
    render json: { a: :b }
  end

  def blank_response
    head :no_content
  end
end

RSpec.describe TestController, type: :controller do
  before(:context) do
    Rails.application.routes.draw do
      get 'test', to: 'test#index'
      get 'blank', to: 'test#blank_response'
    end
  end

  after(:context) { Rails.application.reload_routes! }

  let(:action) { get :index }

  describe 'response logging' do
    before do
      ENV['LOG_RESPONSES'] = 'true'
    end

    it 'logs the response json' do
      Timecop.freeze do
        action
        date = Time.zone.now.to_s(:db)
        filename = "#{date}-#{request.headers['action_dispatch.request_id']}.json"
        path = Rails.root.join 'log', 'responses', filename
        expect(File.read(path)).to eql(JSON.pretty_generate({ a: :b }))
      end
    end

    context 'if response has no body' do
      it 'does not log a response json file' do
        Timecop.freeze 1.minute.from_now do
          get :blank_response
          date = Time.zone.now.to_s(:db)
          filename = "#{date}-#{request.headers['action_dispatch.request_id']}.json"
          path = Rails.root.join 'log', 'responses', filename
          expect(File.exist? path).to be_falsey
        end
      end
    end
  end

  describe 'exception handling' do
    before(:each) do
      expect_any_instance_of(described_class).to \
        receive(:index).and_raise exception, exception_message
    end

    let(:response_json) { JSON.parse(response.body).deep_symbolize_keys }

    subject { response }

    rescued_exceptions = {
      ActiveRecord::StatementInvalid => 400,
      ActionController::ParameterMissing => 400,
      Pagy::OutOfRangeError => 400,
      ActiveRecord::RecordNotFound => 404,
      ActiveRecord::RecordInvalid => {
        status: 400,
        exception_message: User.new,
        error: 'Validation failed',
      },
      ActiveRecord::RecordNotUnique => {
        status: 500,
        error: 'Internal server error. Please try again later',
      },
      PG::ExternalRoutineInvocationException => {
        status: 500,
        error: 'Internal server error. Please try again later',
      },
    }

    rescued_exceptions.each do |exc, hash|
      hash = {
        status: hash,
      } unless hash.is_a? Hash

      hash[:error] ||= exc.to_s
      hash[:exception_message] ||= hash[:error]

      describe exc.to_s do
        let(:exception) { exc }
        let(:exception_message) { hash[:exception_message] }
        it_behaves_like :http_status, hash[:status]
        it_behaves_like :include_in_response_body, hash[:error]
        it { action; is_expected.to match_response_schema('error') }
      end
    end
  end
end
