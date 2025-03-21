defmodule InvoiceGeneratorWeb.InvoiceLive.Index do
  @moduledoc """
  The invoices dashboard.
  """

  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Records, Repo}

  alias InvoiceGenerator.Records.Invoice

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

            <Button.button
              class="bg-[#7c5dfa] rounded-full pl-2 hidden sm:block"
              phx-click={JS.patch(~p"/invoices/new")}
            >
              <Layout.flex flex_direction="row" justify_content="between" class="gap-4">
                <div><img src={~p"/images/invoices/plusbutton.svg"} alt="invoice button" /></div>

                <div>New Invoice</div>
              </Layout.flex>
            </Button.button>

            <Button.button
              class="bg-[#7c5dfa] rounded-full pl-2 block sm:hidden"
              phx-click={JS.patch(~p"/invoices/new")}
            >
              <Layout.flex flex_direction="row" justify_content="between" class="gap-4">
                <div><img src={~p"/images/invoices/plusbutton.svg"} alt="invoice button" /></div>

                <div>New</div>
              </Layout.flex>
            </Button.button>
          </Layout.flex>
        </Layout.flex>

        <%= if @invoices_present == false do %>
          <Layout.flex flex_direction="col" justify_content="center" class="border border-blue-400">
            <section class="mt-32 mb-6">
              <img src={~p"/images/invoices/campaign.svg"} alt="invoice button" />
            </section>
            <Text.subtitle color="black" class="text-2xl font-semibold py-6">
              There is nothing here
            </Text.subtitle>
            <Text.text>Create an invoice by clicking the</Text.text>
            <Text.text>New button and get started</Text.text>
          </Layout.flex>
        <% else %>
          <section id="table_stream_invoices" phx-update="stream" class="py-16">
            <div :for={{dom_id, invoice} <- @streams.invoices} id={"#{dom_id}"}>
              <.live_component
                module={InvoiceGeneratorWeb.InvoiceLive.View.InvoiceComponent}
                id={dom_id}
                invoice_id={invoice.id}
                client_name={invoice.to_client_name}
                invoice_due={invoice.invoice_due}
                invoice_state={invoice.invoice_state}
                invoice_items={invoice.items}
              />
            </div>
          </section>
        <% end %>

        <.modal
          :if={@live_action in [:new, :edit]}
          id="invoices-modal"
          show
          on_cancel={JS.patch(~p"/invoices")}
        >
          <.live_component
            module={InvoiceGeneratorWeb.InvoiceLive.DetailsComponent}
            id="invoice main details form"
            title={@page_title}
            current_user={@current_user.id}
            action={@live_action}
            patch={~p"/invoices"}
          />

          <.live_component
            module={InvoiceGeneratorWeb.InvoiceLive.DateComponent}
            id="invoice date information form"
            current_user={@current_user.id}
            action={@live_action}
          />

          <.live_component
            module={InvoiceGeneratorWeb.InvoiceLive.ItemComponent}
            id="invoice items information form"
            current_user={@current_user.id}
            action={@live_action}
            patch={~p"/invoices"}
          />
        </.modal>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    user_invoices = get_invoices(current_user_id)

    socket = invoices?(user_invoices, socket)

    {:ok,
     socket
     |> stream(:invoices, user_invoices)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Invoice")
    |> assign(:invoice, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Invoices")
    |> assign(:invoice, nil)
  end

  defp get_invoices(user_id) do
    result = Records.get_invoices_by_user_id(user_id)
    result
  end

  @impl true
  def handle_info({:valid_item_details, item_details, status}, socket) do
    item_details =
      Enum.map(item_details, fn map ->
        Map.delete(map, :errors)
      end)

    case Map.get(socket.assigns, :date_details) do
      nil ->
        {:noreply, socket}

      date_details ->
        case Map.get(socket.assigns, :business_details) do
          nil ->
            {:noreply, socket}

          business_details ->
            item_details = %{
              items: item_details,
              invoice_state: status,
              user_id: socket.assigns.current_user.id
            }

            all_details = Map.merge(item_details, date_details)
            all_details = Map.merge(all_details, business_details)

            invoice_changeset = Records.change_invoice(%Invoice{}, all_details)

            case submit_the_invoice(invoice_changeset) do
              {:ok, _record} ->
                {:noreply,
                 socket
                 |> push_patch(to: ~p"/invoices")
                 |> put_flash(:info, "Invoice was Successfully processed")}

              {:error, _changeset} ->
                {:noreply,
                 socket
                 |> push_patch(to: ~p"/invoices")
                 |> put_flash(:error, "Details were not Submitted!!")}
            end
        end
    end
  end

  @impl true
  def handle_info({:valid_date_details, date_details}, socket) do
    {:noreply,
     socket
     |> assign(date_details: date_details)}
  end

  @impl true
  def handle_info({:valid_business_details, business_details}, socket) do
    {:noreply,
     socket
     |> assign(business_details: business_details)}
  end

  defp submit_the_invoice(changeset) do
    Repo.insert(changeset)
  end

  defp invoices?(invoices, socket) do
    case Enum.empty?(invoices) do
      true ->
        assign(socket, :invoices_present, false)

      false ->
        assign(socket, :invoices_present, true)
    end
  end
end
