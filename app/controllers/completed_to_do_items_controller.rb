class CompletedToDoItemsController < ApplicationController
  before_action :set_completed_to_do_item, only: %i[ show edit update destroy ]

  # GET /completed_to_do_items or /completed_to_do_items.json
  def index
    @completed_to_do_items = CompletedToDoItem.all
  end

  # GET /completed_to_do_items/1 or /completed_to_do_items/1.json
  def show
  end

  # GET /completed_to_do_items/new
  def new
    @completed_to_do_item = CompletedToDoItem.new
  end

  # GET /completed_to_do_items/1/edit
  def edit
  end

  # POST /completed_to_do_items or /completed_to_do_items.json
  def create
    @completed_to_do_item = CompletedToDoItem.new(completed_to_do_item_params)

    respond_to do |format|
      if @completed_to_do_item.save
        format.html { redirect_to @completed_to_do_item, notice: "Completed to do item was successfully created." }
        format.json { render :show, status: :created, location: @completed_to_do_item }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @completed_to_do_item.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /completed_to_do_items/1 or /completed_to_do_items/1.json
  def update
    respond_to do |format|
      if @completed_to_do_item.update(completed_to_do_item_params)
        format.html { redirect_to @completed_to_do_item, notice: "Completed to do item was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @completed_to_do_item }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @completed_to_do_item.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /completed_to_do_items/1 or /completed_to_do_items/1.json
  def destroy
    @completed_to_do_item.destroy!

    respond_to do |format|
      format.html { redirect_to completed_to_do_items_path, notice: "Completed to do item was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_completed_to_do_item
      @completed_to_do_item = CompletedToDoItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def completed_to_do_item_params
      params.expect(completed_to_do_item: [ :completed, :completed_at ])
    end
end
