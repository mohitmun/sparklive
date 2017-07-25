class Testadmin::AttemptsController < ApplicationController
  layout "layouts/application"
  helper 'testadmin/surveys'

  before_filter :load_active_survey
  before_filter :normalize_attempts_data, :only => :create

  def new
    @participant = current_user # you have to decide what to do here
    if @survey.blank? && @participant
      @survey = @participant.get_next_survey
    end
    unless @survey.nil?
      @attempt = @survey.attempts.new
      @attempt.answers.build
    else
      @survey = ModuleTest.first
      @attempt = @survey.attempts.new
      @attempt.answers.build
    end
  end

  def show
    @attempt = Attempt.find(params[:id])
    @next_survey = current_user.get_next_survey
  end

  def index
    @attempts = Attempt.all
    if params[:survey_id]
      @attempts = @attempts.where(survey_id: params[:survey_id])
    end
    render layout: "layouts/monologue/admin"
  end

  def destroy
    @attempt = Attempt.find(params[:id])
    @attempt.destroy
    redirect_to attempts_path
  end

  def create
    @attempt = @survey.attempts.new(attempt_params)
    @attempt.participant = @current_user
    if @attempt.valid? && @attempt.save
      redirect_to attempt_path(@attempt), alert: I18n.t("attempts_controller.#{action_name}")
    else
      render :action => :new
    end
  end

  private

  def load_active_survey
    @survey = ModuleTest.find(params[:survey_id]) rescue nil
  end

  def normalize_attempts_data
    normalize_data!(params[:survey_attempt][:answers_attributes])
  end

  def normalize_data!(hash)
    multiple_answers = []
    last_key = hash.keys.last.to_i

    hash.keys.each do |k|
      if hash[k]['option_id'].is_a?(Array)
        if hash[k]['option_id'].size == 1
          hash[k]['option_id'] = hash[k]['option_id'][0]
          next
        else
          multiple_answers <<  k if hash[k]['option_id'].size > 1
        end
      end
    end

    multiple_answers.each do |k|
      hash[k]['option_id'][1..-1].each do |o|
        last_key += 1
        hash[last_key.to_s] = hash[k].merge('option_id' => o)
      end
      hash[k]['option_id'] = hash[k]['option_id'].first
    end
  end

  def attempt_params
    rails4? ? params_whitelist : params[:survey_attempt]
  end

  def params_whitelist
    params.require(:survey_attempt).permit(Survey::Attempt::AccessibleAttributes)
  end
end
