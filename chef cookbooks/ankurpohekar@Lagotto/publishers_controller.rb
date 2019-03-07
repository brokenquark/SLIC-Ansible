class Api::V6::PublishersController < Api::BaseController
  swagger_controller :publishers, "Publishers"

  swagger_api :index do
    summary 'Returns all publishers, sorted by name, 50 per page'
    param :query, :page, :integer, :optional, "Page number"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  swagger_api :show do
    summary 'Returns publisher by name'
    param :path, :id, :string, :required, "name"
    response :ok
    response :not_found
    response :unprocessable_entity
    response :internal_server_error
  end

  def index
    collection = Publisher.order(:name).paginate(:page => params[:page]).all
    @publishers = collection.decorate
  end

  def show
    publisher = Publisher.where(name: params[:id]).first
    @publisher = publisher.decorate
  end
end
