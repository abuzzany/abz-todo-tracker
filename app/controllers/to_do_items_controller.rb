class ToDoItemsController < ApplicationController
  def create
    ToDoItem.create!(to_do_item_params)
    head :created
  end

  private

  def to_do_item_params
    params.require(:to_do_item).permit(:title, :description)
  end
end
