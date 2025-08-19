# app/services/invoice_pdf_generator.rb
require "prawn"
require "prawn/table"

class InvoicePdfGenerator
  def initialize(invoice)
    @invoice = invoice
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
      pdf.text "Factura ##{@invoice.invoice_number}", size: 22, style: :bold
      pdf.move_down 10
      pdf.text "Cliente: #{@invoice.client_name} (#{@invoice.client_email})"
      pdf.text "Dirección: #{@invoice.client_address}"
      pdf.text "Fecha de emisión: #{@invoice.issue_date}"
      pdf.text "Vencimiento: #{@invoice.due_date}"
      pdf.move_down 10
      pdf.text "Notas: #{@invoice.notes}"
      pdf.move_down 20

      pdf.text "Conceptos", style: :bold
      pdf.move_down 5
      table_data = [ [ "Descripción", "Cantidad", "Precio unitario", "Total" ] ]
      @invoice.invoice_items.each do |item|
        table_data << [
          item.description,
          item.quantity,
          sprintf("%.2f", item.unit_price),
          sprintf("%.2f", item.total)
        ]
      end
      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        columns(2..3).align = :right
      end
      pdf.move_down 20
      pdf.text "Subtotal: #{sprintf('%.2f', @invoice.subtotal)} €"
      pdf.text "IVA (#{@invoice.tax_rate}%): #{sprintf('%.2f', @invoice.tax_amount)} €"
      pdf.text "Total: #{sprintf('%.2f', @invoice.total_amount)} €", size: 16, style: :bold
    end.render
  end
end
