class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]

  # GET /entries
  # GET /entries.json
  def index
    @entries = current_user.entries

  end

  # GET /entries/1
  # GET /entries/1.json
  def show
    @prompts = @entry.prompts
        respond_to do |format|
        format.html { }
        format.json { render json: Spark.new(current_user).next_entry, status: :ok }
      end
  end

  # GET /entries/new
  def new
    @entry = Entry.new
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries
  # POST /entries.json
  def create
    if params["answers"]
      entry = Spark.new(current_user).process_entries(params)

      watson_text = Dissonance.prepare_for_watson(entry)
      entry.tone = Dissonance.fetch_tone(watson_text)

      if primary_tone = Dissonance.primary_tone(entry.tone)
        entry.dissonant = Dissonance.is_dissonant?(entry.mood, primary_tone)
      end

      entry.save
      entry.finish!

      head :ok
    else
      @entry = current_user.entries.new(entry_params)

      respond_to do |format|
        if @entry.save
          format.html { redirect_to @entry, notice: 'Entry was successfully created.' }
          format.json { render json: @entry, status: :ok }
        else
          format.html { render :new }
          format.json { render json: @entry.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to @entry, notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to entries_url, notice: 'Entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.fetch(:entry, {})
    end
end
