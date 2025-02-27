defmodule InvoiceGeneratorWeb.InvoiceLive.Index do
  @moduledoc """
  The invoices dashboard.
  """

  use InvoiceGeneratorWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-red-400">
      invoices
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
