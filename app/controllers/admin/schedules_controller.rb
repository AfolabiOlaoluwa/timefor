class Admin::SchedulesController < ApplicationController
  def index
    @user = current_user
    @contacts = policy_scope(Contact)
    @schedules = policy_scope(Schedule)
    @schedule = Schedule.new
    @frequency = Frequency.new
    @timepicker = true
    authorize Schedule
  end

  def new
    @schedule = Schedule.new
    @frequency = Frequency.new
    @user = current_user
    @contacts = policy_scope(Contact)
    @title = "Add Schedule"
    authorize @schedule
  end

  def create
    @schedule = Schedule.new(schedule_params)
    @schedule.user_id = current_user.id
    @frequency = Frequency.new(frequency_params)
    @frequency.schedule = @schedule
    authorize @schedule

    respond_to do |format|
      if @schedule.save && @frequency.save
        @occurence = Occurence.new(schedule: @schedule, time: @frequency.first_occurence)
        @occurence.save
        format.html { redirect_to polymorphic_path([:admin, @schedule]), notice: 'Schedule was successfully created.' }
        format.json { render action: 'add', status: :created, location: [:admin, @schedule] }
        format.js   { render action: 'add', status: :created, location: [:admin, @schedule] }
        @occurence.create_scheduled_call
      else
        format.json { render action: 'error' }
        format.js   { render action: 'error' }
      end
    end
  end

  def clone
    @schedule = Schedule.find(params[:id])
    @schedule = Schedule.new(@schedule.attributes)
    @title = "Copy Schedule"
    render :new
  end


  def destroy
    @schedule = Schedule.find(params[:id])
    @frequency = @schedule.frequency
    authorize @schedule
    if @schedule.destroy
      @frequency.destroy
      flash.now[:success] = "Schedule successfully deleted."
    else
      flash.now[:error] = "There was a problem deleting the Schedule. Please try again."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end


  private

    def schedule_params
      params.require(:schedule).permit(:contact_id, :message)
    end

    def frequency_params
      params.require(:frequency).permit(:schedule_id, :start_datetime_date, :start_datetime_time, :timezone, :repeat, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    end

end
