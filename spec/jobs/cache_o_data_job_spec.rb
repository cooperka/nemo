# frozen_string_literal: true

require "rails_helper"
require "json"

describe CacheODataJob do
  let(:response) { create(:response) }

  # This spec tests the method that caches the JSON, not the JSON itself
  # (see response_json_generator_spec.rb for that).
  describe "basic caching" do
    it "caches a response" do
      expect(response.dirty_json).to be(true)
      json = described_class.cache_response(response)
      expect(json.to_json).to match(/"ResponseReviewed":false/)
      expect(response.dirty_json).to be(false)
    end

    it "returns error json" do
      allow(Results::ResponseJsonGenerator).to receive(:new).and_raise(StandardError)
      expect(response.dirty_json).to be(true)
      json = described_class.cache_response(response)
      expect(json.to_json).to match(/"error":"StandardError"/)
      expect(response.dirty_json).to be(false)
    end

    context "when PartialError is raised" do
      before do
        allow(Sms::Broadcaster).to receive(:deliver).and_raise(Sms::Adapters::PartialSendError)
      end

      it "marks operation as completed" do
        described_class.perform_now(operation, broadcast_id: broadcast.id)
        expect(operation.reload.completed?).to eq(true)
      end

      it "saves job error report" do
        described_class.perform_now(operation, broadcast_id: broadcast.id)
        expect(operation.reload.job_error_report).to match(/errors delivering some messages/)
      end
    end

    context "when FatalError is raised" do
      before do
        allow(Sms::Broadcaster).to receive(:deliver).and_raise(Sms::Adapters::FatalSendError)
      end

      it "marks operation as failed" do
        described_class.perform_now(operation, broadcast_id: broadcast.id)
        expect(operation.reload.failed?).to eq(true)
      end

      it "saves job error report" do
        described_class.perform_now(operation, broadcast_id: broadcast.id)
        expect(operation.reload.job_error_report).to match(/for more information/)
      end
    end
  end
end
