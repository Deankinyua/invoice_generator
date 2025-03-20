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
          <section>#RT3080</section>
          <section>Jensen Huang</section>
        </div>
        <div class="flex justify-between items-center w-[90%] mx-auto">
          <section class="flex flex-col gap-4">
            <div>Due  19 Aug 2021</div>
            <div>£ 1,800.90</div>
          </section>
          <section class="border border-blue-400 py-3 px-6">Status</section>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    %{invoice_items: items} = assigns

    dbg(items)

    {:ok,
     socket
     |> assign(assigns)}
  end
end
