class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :check_subscription, except: [:index]

  def index
    @clients = current_user.clients.includes(:projects, :interactions).recent
    @clients_by_status = @clients.group(:status).count
    @total_value = @clients.sum { |client| client.total_project_value }
    @recent_interactions = current_user.interactions.includes(:client).recent.limit(5)
  end

  def show
    @interactions = @client.interactions.includes(:user).recent
    @projects = @client.projects.recent
    @total_project_value = @client.total_project_value
  end

  def new
    @client = current_user.clients.build
  end

  def create
    @client = current_user.clients.build(client_params)
    @client.created_by = current_user

    if @client.save
      redirect_to @client, notice: 'Cliente creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Cliente actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: 'Cliente eliminado exitosamente.'
  end

  private

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone, :address, :company, 
                                   :tax_id, :website, :notes, :status)
  end

  def check_subscription
    unless current_user.can_manage_clients?
      redirect_to subscription_plans_path, 
                  alert: 'Necesitas una suscripción Pro para gestionar clientes.'
    end
  end
end
