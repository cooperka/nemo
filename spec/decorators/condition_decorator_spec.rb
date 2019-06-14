# frozen_string_literal: true

require "rails_helper"

describe ConditionDecorator do
  describe "human_readable" do
    let(:include_code) { false }
    subject { cond.decorate.human_readable(include_code: include_code) }

    context "for numeric ref question" do
      let(:form) { create(:form, question_types: %w[integer]) }
      let(:int_q) { form.c[0] }
      let(:cond) { Condition.new(left_qing: int_q, op: "lt", value: "5") }

      context "not including code" do
        it { is_expected.to eq("Question #1 is less than 5") }
      end

      context "including code" do
        let(:include_code) { true }
        it { is_expected.to eq("Question #1 [#{int_q.code}] is less than 5") }
      end
    end

    context "for non-numeric ref question" do
      let(:form) { create(:form, question_types: %w[text]) }
      let(:text_q) { form.c[0] }
      let(:cond) { Condition.new(left_qing: text_q, op: "eq", value: "foo") }

      it { is_expected.to eq("Question #1 is equal to \"foo\"") }
    end

    context "for multiselect ref question" do
      let(:form) { create(:form, question_types: %w[select_multiple]) }
      let(:sel_q) { form.c[0] }

      context "positive should work" do
        let(:cond) { Condition.new(left_qing: sel_q, op: "inc", option_node: sel_q.option_set.c[1]) }
        it { is_expected.to eq("Question #1 includes \"Dog\"") }
      end

      context "negation should work" do
        let(:cond) { Condition.new(left_qing: sel_q, op: "ninc", option_node: sel_q.option_set.c[1]) }
        it { is_expected.to eq("Question #1 excludes \"Dog\"") }
      end
    end

    context "for single level select ref question" do
      let(:form) { create(:form, question_types: %w[select_one]) }
      let(:sel_q) { form.c[0] }
      let(:cond) { Condition.new(left_qing: sel_q, op: "eq", option_node: sel_q.option_set.c[1]) }

      it { is_expected.to eq("Question #1 is equal to \"Dog\"") }
    end

    context "for multi level select ref question" do
      let(:form) { create(:form, question_types: %w[multilevel_select_one]) }
      let(:sel_q) { form.c[0] }

      context "matching first level" do
        let(:cond) { Condition.new(left_qing: sel_q, op: "eq", option_node: sel_q.option_set.c[0]) }
        it { is_expected.to eq("Question #1 Kingdom is equal to \"Animal\"") }
      end

      context "matching second level" do
        let(:cond) { Condition.new(left_qing: sel_q, op: "eq", option_node: sel_q.option_set.c[1].c[0]) }

        context "not including code" do
          it { is_expected.to eq("Question #1 Species is equal to \"Tulip\"") }
        end

        context "including code" do
          let(:include_code) { true }
          it { is_expected.to eq("Question #1 [#{sel_q.code}] Species is equal to \"Tulip\"") }
        end
      end
    end

    context "for right side qing" do
      let(:form) { create(:form, question_types: %w[text text text]) }
      let(:cond) { Condition.new(left_qing: form.c[1], op: "eq", right_qing: form.c[0]) }

      context "not including code" do
        it { is_expected.to eq("Question #2 is equal to Question #1") }
      end

      context "including code" do
        let(:include_code) { true }
        it do
          is_expected.to eq("Question #2 [#{form.c[1].code}] is equal to Question #1 [#{form.c[0].code}]")
        end
      end
    end
  end
end
