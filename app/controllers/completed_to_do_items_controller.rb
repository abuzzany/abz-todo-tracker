class CompletedToDoItemsController < ApplicationController
  before_action :set_completed_to_do_item, only: %i[update]

  # PATCH/PUT /completed_to_do_items/1 or /completed_to_do_items/1.json
  def update
    respond_to do |format|
      if @completed_to_do_item.update(completed_to_do_item_params)
        format.html { redirect_to completed_to_do_item_path(@completed_to_do_item), notice: "Completed to do item was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: completed_to_do_item_url(@completed_to_do_item) }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @completed_to_do_item.errors, status: :unprocessable_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_completed_to_do_item
      @completed_to_do_item = ToDoItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def completed_to_do_item_params
      params.expect(completed_to_do_item: [ :completed, :completed_at ])
    end
end
