defmodule InvoiceGeneratorWeb.InvoiceLive.FormComponent do
  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGenerator.{Records, Helpers}
  alias InvoiceGenerator.Records.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <Layout.col>
        <Text.title class="text-xl">
          <Text.bold>{@title}</Text.bold>
        </Text.title>

        <Text.subtitle color="gray">
          Use this form to manage shop records in your database.
        </Text.subtitle>

        <Layout.divider class="my-4" />

        <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Street Address
              </Text.text>
            </label>

            <.input field={@form[:from_address]} type="text" placeholder="Street Address..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                City
              </Text.text>
            </label>

            <.input field={@form[:from_city]} type="text" placeholder="City..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Post Code
              </Text.text>
            </label>

            <.input field={@form[:from_post_code]} type="text" placeholder="Postal Code..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Country
              </Text.text>
            </label>

            <.input field={@form[:from_country]} type="text" placeholder="Country..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Client's Name
              </Text.text>
            </label>

            <.input field={@form[:to_client_name]} type="text" placeholder="Client's Name..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Client's Email
              </Text.text>
            </label>

            <.input field={@form[:to_client_email]} type="text" placeholder=" Client's Email..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Street Address
              </Text.text>
            </label>

            <.input field={@form[:to_address]} type="text" placeholder="Street Address..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                City
              </Text.text>
            </label>

            <.input field={@form[:to_city]} type="text" placeholder="City..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Post Code
              </Text.text>
            </label>

            <.input field={@form[:to_post_code]} type="text" placeholder="Postal Code..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Country
              </Text.text>
            </label>

            <.input field={@form[:to_country]} type="text" placeholder="Country..." />
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Invoice Date
              </Text.text>
            </label>

            <div>
              <DatePicker.date_picker
                id="invoice_date"
                date={Date.to_string(@form[:invoice_date].value)}
                on_change="change_date"
                day_indicator_class="bg-[#7c5dfa]"
              />
            </div>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Payment Terms
              </Text.text>
            </label>
            <Select.search_select
              id="country_id"
              name={@form[:invoice_due].name}
              placeholder="Payment terms"
              value={@form[:invoice_due].value}
            >
              <:item :for={%{name: name} <- @payment_terms}>
                {name}
              </:item>
            </Select.search_select>
          </Layout.col>

          <Layout.col class="space-y-1.5">
            <label for="name_field">
              <Text.text class="text-tremor-content">
                Project Description
              </Text.text>
            </label>

            <.input field={@form[:project_description]} type="text" placeholder="Postal Code..." />
          </Layout.col>

          <div class="border border-red-400">
            <%= for item <- @items do %>
              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Item Name
                  </Text.text>
                </label>

                <.input field={@form[item.name]} type="text" placeholder="Item Name..." />
              </Layout.col>

              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Quantity
                  </Text.text>
                </label>

                <.input field={@form[item.quantity]} type="number" placeholder="Quantity..." />
              </Layout.col>

              <Layout.col class="space-y-1.5">
                <label for="name_field">
                  <Text.text class="text-tremor-content">
                    Price
                  </Text.text>
                </label>

                <.input field={@form[item.price]} type="number" placeholder="Price..." />
              </Layout.col>

              <Button.button
                variant="secondary"
                size="xs"
                class="mt-2 w-min"
                phx-click={JS.push("remove_item", value: %{id: item.id})}
                phx-target={@myself}
              >
                Remove Item
              </Button.button>
            <% end %>
          </div>

          <Button.button
            variant="secondary"
            size="xl"
            class="mt-2 w-min"
            phx-click={JS.push("add_new_item")}
            phx-target={@myself}
          >
            Add new item
          </Button.button>

          <Button.button type="submit" size="xl" class="mt-2 w-min" phx-disable-with="Saving...">
            Create Invoice
          </Button.button>
        </.form>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:items, [])
     |> assign(payment_terms: Helpers.payment_terms())
     |> assign(item_count: 0)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    date = socket.assigns.invoice_date

    invoice_date_map = %{"invoice_date" => date}

    invoice_params = Map.merge(invoice_params, invoice_date_map)

    invoice = socket.assigns.invoice

    socket = create_and_assign_form(socket, invoice, invoice_params)

    {:noreply, socket}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    due_days = invoice_params["invoice_due"]
    map = Helpers.string_mappings_of_days()
    days = map[due_days]
    dbg(days)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_new_item", _params, socket) do
    items = socket.assigns.items

    count = socket.assigns.item_count

    new_count = count + 1

    name = "product-" <> Integer.to_string(new_count)
    quantity = "product-" <> Integer.to_string(new_count) <> "-quantity"
    price = "product-" <> Integer.to_string(new_count) <> "-price"

    new_item = %{
      id: new_count,
      name: String.to_atom(name),
      quantity: String.to_atom(quantity),
      price: String.to_atom(price)
    }

    # to append the new_item into our list
    new_items = items ++ [new_item]

    {
      :noreply,
      socket
      |> assign(item_count: new_count)
      |> assign(:items, new_items)
    }
  end

  @impl true
  def handle_event("remove_item", %{"id" => id}, socket) do
    items = socket.assigns.items

    item =
      Enum.filter(items, fn x -> x.id == id end)
      |> Enum.at(0)

    new_items =
      Enum.filter(items, fn x -> x != item end)

    {:noreply,
     socket
     |> assign(items: new_items)}
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket) do
    user_id = socket.assigns.current_user

    case Helpers.get_user(user_id) do
      nil ->
        invoice = %Invoice{user_id: user_id, invoice_date: Date.utc_today()}

        socket = create_and_assign_form(socket, invoice)
        socket

      user_profile ->
        invoice = %Invoice{
          user_id: user_id,
          from_address: user_profile.street,
          from_city: user_profile.city,
          from_country: user_profile.country,
          from_post_code: user_profile.postal_code,
          invoice_date: Date.utc_today()
        }

        socket = create_and_assign_form(socket, invoice)
        socket
    end
  end

  defp create_and_assign_form(socket, invoice, params \\ %{}) do
    changeset = Records.change_invoice(invoice, params)

    form = to_form(changeset, as: "invoice")

    socket =
      socket
      |> assign(invoice: invoice)
      |> assign(form: form)

    socket
  end
end
