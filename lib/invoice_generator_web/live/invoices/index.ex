defmodule InvoiceGeneratorWeb.InvoiceLive.Index do
  @moduledoc """
  The invoices dashboard.
  """

  use InvoiceGeneratorWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?email=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}

      <div class="w-[95%] mx-auto">
        <Layout.flex flex_direction="row" justify_content="between" class="border border-red-400">
          <Layout.flex flex_direction="col" align_items="start" class="border border-red-400">
            <section>Invoices</section>
            <section>No invoices</section>
          </Layout.flex>

          <Layout.flex flex_direction="row">
            <section>filter</section>

            <Button.button class="mt-2 w-min">
              New
            </Button.button>
          </Layout.flex>
        </Layout.flex>
      </div>
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
