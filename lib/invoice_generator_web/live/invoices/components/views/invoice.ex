defmodule InvoiceGeneratorWeb.InvoiceLive.View.InvoiceComponent do
  use InvoiceGeneratorWeb, :live_component

  # alias InvoiceGenerator.{Records, Helpers}
  # alias InvoiceGenerator.Records.Invoice

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-[90%] mx-auto">
      <div class="flex border border-blue-400 hidden md:block">
        <div class="w-[90%] mx-auto flex">
          <section>#RT3080</section>
          <section>Due  19 Aug 2021</section>
        </div>
        <div class="flex">
          <section>Jensen Huang</section>
          <section>£ 1,800.90</section>
        </div>
        <div class="flex">
          <section>Status</section>
          <section>Arrow</section>
        </div>
      </div>

      <div class="flex flex-col border border-blue-400 rounded-lg gap-4 mb-8 md:hidden">
        <div class="flex justify-between items-center w-[90%] mx-auto">
          <section>
            #{first_six_letters(@invoice_id)}
          </section>
          <section>{@client_name}</section>
        </div>
        <div class="flex justify-between items-center w-[90%] mx-auto">
          <section class="flex flex-col gap-4">
            <div>Due {date_formatter(@invoice_due)}</div>
            <div>£ {format_total(@invoice_total)}</div>
          </section>
          <section class="border border-blue-400 py-3 px-6">
            {@invoice_state}
          </section>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    %{invoice_items: items} = assigns

    total = get_total_invoice_cost(items)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(invoice_total: total)}
  end

  def get_total_invoice_cost(items) do
    total = Enum.reduce(items, 0, fn x, acc -> x.total + acc end)
    total
  end

  def first_six_letters(word) when is_binary(word) do
    String.slice(word, 0, 6)
    |> String.upcase()
  end

  defp date_formatter(date) do
    year = date.year
    day = date.day
    month = date.month

    month_index = month - 1

    list_of_months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ]

    "#{day} #{Enum.at(list_of_months, month_index)} #{year}"
  end

  defp format_total(total) do
    formatted = :io_lib.format("~.2f", [total * 1.0]) |> to_string()
    formatted
  end
end
