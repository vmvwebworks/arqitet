class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = Conversation.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
  end

  def show
    @conversation = Conversation.find(params[:id])
    unless [@conversation.sender_id, @conversation.recipient_id].include?(current_user.id)
      redirect_to conversations_path, alert: 'No autorizado.'
    end
    @messages = @conversation.messages.order(:created_at)
    @message = Message.new
  end

  def create
    recipient = User.find(params[:recipient_id])
    conversation = Conversation.between(current_user.id, recipient.id).first_or_create(sender: current_user, recipient: recipient)
    redirect_to conversation_path(conversation)
  end
end
