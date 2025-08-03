module Admin
  class ConsentTextsController < ApplicationController
    before_action :set_consent_text, only: %i[edit update]
    def index
      @consent_texts = ConsentText.all
    end

    def edit; end

    def update
      if @consent_text.update(consent_text_params)
        redirect_to admin_consent_texts_path, notice: 'Texto actualizado correctamente.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
    def set_consent_text
      @consent_text = ConsentText.find(params[:id])
    end
    def consent_text_params
      params.require(:consent_text).permit(:content, :locale)
    end
  end
end
