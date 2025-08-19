class InteractionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_interaction, only: [ :show, :edit, :update, :destroy ]

  def new
    @interaction = @client.interactions.build
    @interaction.date = Time.current
  end

  def create
    @interaction = @client.interactions.build(interaction_params)
    @interaction.user = current_user

    if @interaction.save
      redirect_to @client, notice: "Interacción registrada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @interaction.update(interaction_params)
      redirect_to @client, notice: "Interacción actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @interaction.destroy
    redirect_to @client, notice: "Interacción eliminada exitosamente."
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_interaction
    @interaction = @client.interactions.find(params[:id])
  end

  def interaction_params
    params.require(:interaction).permit(:interaction_type, :subject, :content, :date)
  end
end
