defmodule InvoiceGeneratorWeb.InvoiceLive.Show do
  @moduledoc """
  Shows an Individual Invoice.
  """

  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGeneratorWeb.InvoiceLive.DeadView.InvoiceHelper
  alias InvoiceGeneratorWeb.InvoiceLive.View.InvoiceComponent
  alias InvoiceGenerator.{Records, Repo}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-[#F8F8FB] w-full h-full">
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?email=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}

      <div class="min-h-screen mx-6 sm:ml-32 sm:mr-10 sm:py-6">
        <Layout.flex
          flex_direction="col"
          justify_content="between"
          class="gap-5 border border-blue-400 sm:hidden"
        >
          <div class="w-full mt-8">
            <.link navigate={~p"/invoices"}>
              <div class="flex items-center gap-6">
                <section>
                  <img src={~p"/images/invoices/back_arrow2.svg"} alt="Back Arrow 2" />
                </section>
                <section class="league-spartan-bold text-[#0C0E16]">Go back</section>
              </div>
            </.link>
          </div>

          <div class="w-full bg-[#FFFFFF] rounded-lg py-8 mt-4">
            <div class="flex justify-between gap-10 items-center w-[90%] mx-auto">
              <div class="text-sm league-spartan-medium text-[#858BB2]">Status</div>
              <div>
                <InvoiceHelper.invoice_state_button invoice_state={@invoice_state} />
              </div>
            </div>
          </div>
          <section class="w-full bg-[#FFFFFF] rounded-lg">
            <div class="flex flex-col gap-10 w-[90%] mx-auto my-6 text-sm text-[#7E88C3]">
              <div>
                <section class="league-spartan-bold text-[#858BB2]">
                  #<span class="text-[#0C0E16]">{InvoiceComponent.first_six_letters(@invoice_id)}</span>
                </section>

                <section class="league-spartan-medium">
                  {@description}
                </section>
              </div>
              <div class="league-spartan-medium">
                <p>
                  {@sender_address}
                </p>
                <p>
                  {@sender_city}
                </p>
                <p>
                  {@sender_postcode}
                </p>
                <p>
                  {@sender_country}
                </p>
              </div>
              <div class="flex flex-col gap-3 league-spartan-medium">
                <div class="flex gap-2">
                  <section class="w-[50%]">
                    Invoice Date
                  </section>
                  <section>Bill To</section>
                </div>
                <div class="flex gap-2 text-[#0C0E16] league-spartan-bold text-base">
                  <section class="w-[50%]">{InvoiceComponent.date_formatter(@invoice_date)}</section>
                  <section>{@receiver_name}</section>
                </div>

                <div class="flex gap-8">
                  <section class="w-[50%] flex flex-col gap-2">
                    <div class="mt-6">
                      Payment Due
                    </div>
                    <div class="text-[#0C0E16] league-spartan-bold text-base">
                      {InvoiceComponent.date_formatter(@due_date)}
                    </div>
                  </section>
                  <section>
                    <p>
                      {@receiver_address}
                    </p>
                    <p>
                      {@receiver_city}
                    </p>
                    <p>
                      {@receiver_postcode}
                    </p>
                    <p>
                      {@receiver_country}
                    </p>
                  </section>
                </div>
              </div>

              <div class="flex flex-col gap-3">
                <section class="league-spartan-medium">Sent to</section>
                <section class="text-base league-spartan-bold text-[#0C0E16]">
                  {@receiver_email}
                </section>
              </div>

              <div class="rounded-lg bg-[#F9FAFE] overflow-hidden">
                <div class="w-[85%] mx-auto my-6 flex flex-col gap-4">
                  <%= for item <- @items do %>
                    <section class="flex items-center justify-between gap-6">
                      <div class="flex flex-col gap-2
    ">
                        <section class="league-spartan-bold text-base text-[#0C0E16]">
                          {item.name}
                        </section>
                        <section class="league-spartan-medium">
                          {item.quantity} x £ {InvoiceComponent.format_total(item.price)}
                        </section>
                      </div>
                      <div class="league-spartan-bold text-base text-[#0C0E16]">
                        £ {InvoiceComponent.format_total(item.total)}
                      </div>
                    </section>
                  <% end %>
                </div>

                <div class="bg-[#373B53] py-8 flex justify-center items-center gap-20 text-[#FFFFFF]">
                  <section class="league-spartan-medium">
                    Grand Total
                  </section>
                  <section class="text-2xl league-spartan-bold">
                    £ {InvoiceComponent.format_total(@total_item_cost)}
                  </section>
                </div>
              </div>
            </div>
          </section>

          <div class="w-full bg-[#FFFFFF] flex justify-center gap-3 py-6">
            <section>
              <button
                class="bg-[#F9FAFE] rounded-full text-[#7E88C3] league-spartan-bold rounded-full px-6 py-3"
                phx-click={JS.patch(return_edit_path(@invoice_id))}
              >
                Edit
              </button>
            </section>
            <section>
              <button
                class="bg-[#EC5757] rounded-full text-[#FFFFFF] league-spartan-bold rounded-full px-6 py-3"
                phx-click={JS.push("delete", value: %{invoice_id: @invoice_id})}
                data-confirm="Are you sure?"
              >
                Delete
              </button>
            </section>
            <section>
              <button
                class="bg-[#7C5DFA] rounded-full text-[#FFFFFF] league-spartan-bold rounded-full px-6 py-3"
                phx-click={JS.push("mark_as_paid", value: %{invoice_id: @invoice_id})}
              >
                Mark as Paid
              </button>
            </section>
          </div>
        </Layout.flex>

        <.live_component
          module={InvoiceGeneratorWeb.InvoiceLive.Show.InvoiceLarge}
          id="individual invoice at large screen size"
          invoice_id={@invoice_id}
          description={@description}
          invoice_state={@invoice_state}
          invoice_date={@invoice_date}
          due_date={@due_date}
          sender_address={@sender_address}
          sender_country={@sender_country}
          sender_postcode={@sender_postcode}
          sender_city={@sender_city}
          receiver_address={@receiver_address}
          receiver_country={@receiver_country}
          receiver_postcode={@receiver_postcode}
          receiver_city={@receiver_city}
          receiver_email={@receiver_email}
          receiver_name={@receiver_name}
          items={@items}
          total_item_cost={@total_item_cost}
        />
      </div>
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

    socket = assign_invoice_details(invoice, socket)
    {:noreply, socket}
  end

  defp assign_invoice_details(invoice, socket) do
    invoice_id = invoice.id

    description = invoice.project_description

    invoice_state = invoice.invoice_state

    invoice_date = invoice.invoice_date
    due_date = invoice.invoice_due

    sender_address = invoice.from_address
    receiver_address = invoice.to_address

    sender_city = invoice.from_city
    receiver_city = invoice.to_city

    sender_postcode = invoice.from_post_code
    receiver_postcode = invoice.to_post_code

    sender_country = invoice.from_country
    receiver_name = invoice.to_client_name
    receiver_country = invoice.to_country
    receiver_email = invoice.to_client_email

    invoice_items = invoice.items
    total_item_cost = InvoiceComponent.get_total_invoice_cost(invoice_items)

    socket =
      socket
      |> assign(invoice_id: invoice_id)
      |> assign(description: description)
      |> assign(invoice_state: invoice_state)
      |> assign(invoice_date: invoice_date)
      |> assign(due_date: due_date)
      |> assign(sender_address: sender_address)
      |> assign(sender_city: sender_city)
      |> assign(sender_postcode: sender_postcode)
      |> assign(sender_country: sender_country)
      |> assign(receiver_address: receiver_address)
      |> assign(receiver_city: receiver_city)
      |> assign(receiver_postcode: receiver_postcode)
      |> assign(receiver_country: receiver_country)
      |> assign(receiver_email: receiver_email)
      |> assign(receiver_name: receiver_name)
      |> assign(total_item_cost: total_item_cost)
      |> assign(items: invoice_items)

    socket
  end

  def return_edit_path(id) do
    ~p"/invoices/#{id}/edit"
  end

  @impl true
  def handle_event("delete", %{"invoice_id" => id}, socket) do
    invoice = Records.get_invoice!(id)

    _result = Repo.delete(invoice)

    {:noreply,
     socket
     |> put_flash(:info, "The invoice #{InvoiceComponent.first_six_letters(id)} was deleted")
     |> push_navigate(to: "/invoices")}
  end

  @impl true
  def handle_event("mark_as_paid", %{"invoice_id" => id}, socket) do
    invoice = Records.get_invoice!(id)

    invoice_changeset = Records.change_invoice(invoice, %{invoice_state: :Paid})

    if invoice_changeset.changes == %{} do
      {:noreply,
       socket
       |> put_flash(
         :error,
         "The invoice #{InvoiceComponent.first_six_letters(id)} is already paid"
       )
       |> push_patch(to: "/invoices/#{id}")}
    else
      case Repo.update(invoice_changeset) do
        {:ok, _record} ->
          {:noreply,
           socket
           |> put_flash(
             :info,
             "The invoice #{InvoiceComponent.first_six_letters(id)} was updated"
           )
           |> push_patch(to: "/invoices/#{id}")}

        {:error, _changeset} ->
          {:noreply,
           socket
           |> put_flash(
             :error,
             "The invoice  #{InvoiceComponent.first_six_letters(id)} was not updated"
           )
           |> push_patch(to: "/invoices/#{id}")}
      end
    end
  end
end
