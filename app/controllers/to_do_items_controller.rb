class ToDoItemsController < ApplicationController
  before_action :set_to_do_item, only: %i[ show edit update destroy ]

  # GET /to_do_items or /to_do_items.json
  def index
    @to_do_items = ToDoItem.all
  end

  # GET /to_do_items/1 or /to_do_items/1.json
  def show
  end

  # GET /to_do_items/new
  def new
    @to_do_item = ToDoItem.new
  end

  # GET /to_do_items/1/edit
  def edit
  end

  # POST /to_do_items or /to_do_items.json
  def create
    @to_do_item = ToDoItem.new(to_do_item_params)

    respond_to do |format|
      if @to_do_item.save
        format.html { redirect_to @to_do_item, notice: "To do item was successfully created." }
        format.json { render :show, status: :created, location: @to_do_item }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @to_do_item.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /to_do_items/1 or /to_do_items/1.json
  def update
    respond_to do |format|
      if @to_do_item.update(to_do_item_params)
        format.html { redirect_to @to_do_item, notice: "To do item was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @to_do_item }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @to_do_item.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /to_do_items/1 or /to_do_items/1.json
  def destroy
    @to_do_item.destroy!

    respond_to do |format|
      format.html { redirect_to to_do_items_path, notice: "To do item was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_to_do_item
      @to_do_item = ToDoItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def to_do_item_params
      params.expect(to_do_item: [ :title, :description, :completed, :completed_at ])
    end
end
