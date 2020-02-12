# frozen_string_literal: true

# Actions for QingGroups
# All requests in this controller are AJAX based.
class QingGroupsController < ApplicationController
  include ConditionFormable
  include Parameters

  # authorization via cancan
  load_and_authorize_resource

  before_action :prepare_qing_group, only: [:create]
  before_action :validate_destroy, only: [:destroy]

  def new
    @form = Form.find(params[:form_id])
    # Adding group requires same permissions as removing questions.
    authorize!(:add_questions, @form)
    @qing_group = QingGroup.new(
      form: @form,
      ancestry: @form.root_id,
      one_screen: true,
      mission: current_mission
    ).decorate
    render(partial: "modal")
  end

  def edit
    @qing_group = QingGroup.find(params[:id]).decorate

    # The QingGroupDecorator might declare this group can't do one-screen even if the property is
    # set to true. If so, we should disable the checkbox.
    @one_screen_disabled = true unless odk_decorator.one_screen_allowed?

    render(partial: "modal")
  end

  def create
    # Adding group requires same permissions as removing questions.
    authorize!(:add_questions, @qing_group.form)
    @qing_group.parent = @qing_group.form.root_group
    if @qing_group.save
      render(partial: "group", locals: {qing_group: @qing_group.decorate})
    else
      # flash[:error] = @qing_group.errors.full_messages.join(", ")
      # TODO: Return a smaller partial, re-render via JS.
      render(partial: "modal")
    end
  end

  def show
    @qing_group = QingGroup.find(params[:id]).decorate
    render(partial: "modal")
  end

  def update
    if @qing_group.update(qing_group_params)
      render(partial: "group_inner", locals: {qing_group: @qing_group.decorate})
    else
      # flash[:error] = @qing_group.errors.full_messages.join(", ")
      render(partial: "modal")
    end
  end

  def destroy
    # Removing group requires same permissions as removing questions.
    authorize!(:remove_questions, @qing_group.form)
    @qing_group.destroy
    render(body: nil, status: :no_content)
  end

  private

  def validate_destroy
    return render(json: [], status: :not_found) unless @qing_group.children.empty?
  end

  # prepares qing_group
  def prepare_qing_group
    attrs = qing_group_params
    attrs[:ancestry] = Form.find(attrs[:form_id]).root_id
    @qing_group = QingGroup.accessible_by(current_ability).new(attrs)
    @qing_group.mission = current_mission
  end

  def qing_group_params
    condition_params = [:id, :left_qing_id, :op, :value, :_destroy, option_node_ids: []]
    translation_keys = permit_translations(params[:qing_group], :group_name, :group_hint, :group_item_name)
    params.require(:qing_group).permit(
      %i[form_id repeatable one_screen] + translation_keys,
      display_conditions_attributes: condition_params
    )
  end

  def odk_decorator
    Odk::DecoratorFactory.decorate(@qing_group.object)
  end
end
