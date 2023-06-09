# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update destroy]

  # GET /invoices or /invoices.json
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1 or /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new
    @invoice.file.attach(params[:file])
    if (@invoice.file.filename.to_s.split('.').last == 'isdoc') || (@invoice.file.filename.to_s.split('.').last == 'isdocx')
      @invoice.save!
      if @invoice.file.filename.to_s.split('.').last == 'isdoc'
        ActionCable.server.broadcast 'preview_channel',
                                     { path: @invoice.id,
                                       user: cookies[:current_user] }
      elsif @invoice.file.filename.to_s.split('.').last == 'isdocx'
        path_to_odf = IsdocxExtractor.new(Invoice.find(@invoice.id)).path
        ActionCable.server.broadcast 'pdf_preview_channel',
                                     { path: path_to_odf,
                                       user: cookies[:current_user] }
      end
    else
      render plain: 'Vkládejte pouze .isdoc soubory', status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html do
          redirect_to invoice_url(@invoice), notice: 'Invoice was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:name)
  end
end
