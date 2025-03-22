defmodule InvoiceGeneratorWeb.InvoiceLive.Show do
  @moduledoc """
  Shows an Individual Invoice.
  """

  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Records, Repo}

  alias InvoiceGenerator.Records.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex flex_direction="col" justify_content="between" class="gap-2 border border-red-400">
        <section>status</section>
        <section>content</section>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    invoice = Records.get_invoice!(id)

    dbg(invoice)

    {:noreply, socket}
  end
end
