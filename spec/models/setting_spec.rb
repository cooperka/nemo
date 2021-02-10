# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: settings
#
#  id                           :uuid             not null, primary key
#  default_outgoing_sms_adapter :string(255)
#  frontlinecloud_api_key       :string(255)
#  generic_sms_config           :jsonb
#  incoming_sms_numbers         :text
#  incoming_sms_token           :string(255)
#  override_code                :string(255)
#  preferred_locales            :string(255)      not null
#  theme                        :string           default("nemo"), not null
#  timezone                     :string(255)      not null
#  twilio_account_sid           :string(255)
#  twilio_auth_token            :string(255)
#  twilio_phone_number          :string(255)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  mission_id                   :uuid
#
# Indexes
#
#  index_settings_on_mission_id  (mission_id) UNIQUE
#
# Foreign Keys
#
#  settings_mission_id_fkey  (mission_id => missions.id) ON DELETE => restrict ON UPDATE => restrict
#
# rubocop:enable Layout/LineLength

require "rails_helper"

describe Setting do
  let(:setting) { get_mission.setting }

  it "serialized locales are always symbols" do
    expect(setting.preferred_locales.first.class).to eq(Symbol)
    setting.update!(preferred_locales_str: "fr,ar")
    expect(setting.preferred_locales.first.class).to eq(Symbol)
  end

  it "locales with spaces should still be accepted" do
    setting.update!(preferred_locales_str: "fr , ar1")
    expect(setting.preferred_locales).to eq(%i[fr ar])
  end

  it "generate override code will generate a new six character code" do
    previous_code = setting.override_code
    setting.generate_override_code!
    expect(previous_code).not_to eq(setting.override_code)
    expect(setting.override_code.size).to eq(6)
  end

  describe ".for_mission cache" do
    # We want to load the thing once per request. How does query cache work? Like that but one level higher.
    # In app controller, we could enable Settings cache in around_action, cover with system spec
    # Also in around_perform for jobs, cover with job spec
    context "without cache enabled" do
      it "queries DB each time" do
        Setting.for_mission(nil)
        expect { 3.times { Setting.for_mission(nil) } }.to make_database_queries(count: 3)
      end
    end

    context "with cache enabled" do
      around do |example|
        Setting.with_cache { example.run }
      end

      it "preforms fewer queries" do
        Setting.for_mission(nil)
        expect { 3.times { Setting.for_mission(nil) } }.not_to make_database_queries
      end

      it "does not save queries on new threads" do
        # Starting a new thread means no cache. Within the thread, we expect that the cache doesn't
        # save on queries.
        Thread.new do
          Setting.for_mission(nil)
          expect { 3.times { Setting.for_mission(nil) } }.to make_database_queries(count: 3)
        end
      end
    end
  end

  describe ".build_default" do
    let(:mission) { get_mission }

    context "with existing admin mode setting" do
      let!(:admin_setting) { Setting.root.update_attribute(:theme, "elmo") }

      it "copies theme setting from admin mode setting" do
        expect(Setting.build_default(mission).theme).to eq("elmo")
      end
    end

    context "without existing admin mode setting" do
      it "defaults to nemo" do
        expect(Setting.build_default(mission).theme).to eq("nemo")
      end
    end
  end

  describe "validation" do
    describe "generic_sms_config_str" do
      it "should error if invalid json" do
        setting = build(:setting,
          mission_id: get_mission.id,
          generic_sms_config_str: "{")
        expect(setting).to be_invalid
        expect(setting.errors[:generic_sms_config_str].join).to match(/JSON error:/)
      end

      it "should error if invalid keys" do
        setting = build(:setting,
          mission_id: get_mission.id,
          generic_sms_config_str: '{"params":{"from":"x", "body":"y"}, "response":"x", "foo":"y"}')
        expect(setting).to be_invalid
        expect(setting.errors[:generic_sms_config_str].join).to match(/Valid keys are params/)
      end

      it "should error if missing top-level key" do
        setting = build(:setting,
          mission: get_mission,
          generic_sms_config_str: '{"params":{"from":"x", "body":"y"}}')
        expect(setting).to be_invalid
        expect(setting.errors[:generic_sms_config_str].join).to match(/Configuration must include/)
      end

      it "should error if missing second-level key" do
        setting = build(:setting,
          mission: get_mission,
          generic_sms_config_str: '{"params":{"from":"x"}, "response":"x"}')
        expect(setting).to be_invalid
        expect(setting.errors[:generic_sms_config_str].join).to match(/Configuration must include/)
      end

      it "should not error if required keys present" do
        setting = build(:setting,
          mission: get_mission,
          generic_sms_config_str: '{"params":{"from":"x", "body":"y"}, "response":"x"}')
        expect(setting).to be_valid
      end
    end
  end
end
