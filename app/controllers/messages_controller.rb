class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message_form", partial: "messages/form", locals: { conversation: @conversation, message: @message }) }
        format.html { render "conversations/show", status: :unprocessable_entity }
      end
    end
  end

  private
    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
      unless [ @conversation.sender_id, @conversation.recipient_id ].include?(current_user.id)
        redirect_to conversations_path, alert: "No autorizado."
      end
    end

    def message_params
      params.require(:message).permit(:body)
    end
end
