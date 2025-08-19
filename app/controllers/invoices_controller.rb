class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: [ :show, :edit, :update, :destroy, :pdf, :mark_as_sent, :mark_as_paid ]

  def index
    @invoices = current_user.invoices.includes(:project).recent
    @total_pending = @invoices.pending.sum(:total_amount)
    @total_paid = @invoices.paid.sum(:total_amount)
    @overdue_count = @invoices.select(&:overdue?).count
  end

  def show
  end

  def new
    @invoice = current_user.invoices.build
    @invoice.issue_date = Date.current
    @invoice.due_date = Date.current + 30.days
    @invoice.invoice_items.build
    @projects = current_user.projects.active
  end

  def create
    @invoice = current_user.invoices.build(invoice_params)

    if @invoice.save
      redirect_to @invoice, notice: "Factura creada exitosamente."
    else
      @projects = current_user.projects.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @projects = current_user.projects.active
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Factura actualizada exitosamente."
    else
      @projects = current_user.projects.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Factura eliminada exitosamente."
  end

  def mark_as_sent
    @invoice.update(status: :sent)
    redirect_to @invoice, notice: "Factura marcada como enviada."
  end

  def mark_as_paid
    @invoice.update(status: :paid)
    redirect_to @invoice, notice: "Factura marcada como pagada."
  end

  def pdf
    pdf = InvoicePdfGenerator.new(@invoice).render
    send_data pdf, filename: "factura_#{@invoice.invoice_number}.pdf", type: "application/pdf", disposition: "inline"
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:project_id, :client_name, :client_email,
                                   :client_address, :tax_rate, :issue_date, :due_date,
                                   :notes, :status,
                                   invoice_items_attributes: [ :id, :description, :quantity,
                                                            :unit_price, :_destroy ])
  end
end
