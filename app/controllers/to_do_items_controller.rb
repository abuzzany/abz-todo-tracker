class ToDoItemsController < ApplicationController
  ITEMS_PER_PAGE = 15

  before_action :set_to_do_item, only: %i[ show edit update destroy ]

  # GET /to_do_items or /to_do_items.json
  def index
    paginate_to_do_items

    completed_by_day = ToDoItem.where(completed: true)
                                .group("DATE(completed_at)")
                                .count

    completed_by_category = ToDoItem.where(completed: true)
                                .joins(:category)
                                .group("categories.name")
                                .group_by_day(:completed_at)
                                .count

    by_category = Hash.new { |h, k| h[k] = {} }
    completed_by_category.each do |(category, date), count|
      by_category[category][date] = count
    end

    @completed_chart_data = [ { name: "Total", data: completed_by_day } ] +
      by_category.map { |category, data| { name: category, data: data } }

    @completed_counts_by_day = ToDoItem.completed_counts_by_day
    streak = CompletionStreak.new(@completed_counts_by_day.keys)
    @current_streak = streak.current
    @longest_streak = streak.longest
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
    @to_do_item = ToDoItem.new(to_do_item_params_with_category)

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
      if @to_do_item.update(to_do_item_params_with_category)
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
    # Loads one page of items into @to_do_items. Out-of-range or invalid
    # ?page= values are clamped to the first/last page instead of erroring.
    def paginate_to_do_items
      @per_page = ITEMS_PER_PAGE
      scope = ToDoItem.includes(:category).order(:id)
      @total_count = scope.count
      @total_pages = [ (@total_count / @per_page.to_f).ceil, 1 ].max
      @page = params[:page].to_i.clamp(1, @total_pages)
      @to_do_items = scope.limit(@per_page).offset((@page - 1) * @per_page)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_to_do_item
      @to_do_item = ToDoItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def to_do_item_params
      params.expect(to_do_item: [ :category_id, :title, :description, :completed, :completed_at ])
    end

    # Merges in a freshly persisted category when the user typed a new one,
    # taking priority over whatever was selected in the dropdown.
    def to_do_item_params_with_category
      attrs = to_do_item_params
      new_category_name.present? ? attrs.merge(category_id: find_or_create_category.id) : attrs
    end

    def new_category_name
      params[:new_category].to_s.strip
    end

    def find_or_create_category
      Category.where("lower(name) = ?", new_category_name.downcase).first ||
        Category.create!(name: new_category_name)
    end
end
