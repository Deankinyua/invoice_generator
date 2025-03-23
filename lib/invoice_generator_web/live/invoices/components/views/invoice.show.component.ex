defmodule InvoiceGeneratorWeb.InvoiceLive.Show.InvoiceLarge do
  @moduledoc """
  the invoice at large screen sizes
  """

  use InvoiceGeneratorWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto hidden sm:block border border-blue-400">
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

      <div class="py-6 border border-red-400 rounded-lg mb-10 bg-[#FFFFFF]">
        <div class="w-[92%] mx-auto flex justify-between items-center">
          <section class="flex gap-4">
            <div>Status</div>
            <div>Pending</div>
          </section>
          <section class="flex gap-4">
            <section>
              <Button.button
                class="bg-[#7c5dfa] rounded-full pl-2"
                phx-click={JS.patch(~p"/invoices/new")}
              >
                Edit
              </Button.button>
            </section>
            <section>
              <Button.button
                class="bg-[#7c5dfa] rounded-full pl-2"
                phx-click={JS.patch(~p"/invoices/new")}
              >
                Delete
              </Button.button>
            </section>
            <section>
              <Button.button
                class="bg-[#7c5dfa] rounded-full pl-2"
                phx-click={JS.patch(~p"/invoices/new")}
              >
                Mark as Paid
              </Button.button>
            </section>
          </section>
        </div>
      </div>
      <div class="py-6 border border-red-400 rounded-lg bg-[#FFFFFF]">
        <div class="w-[86%] mx-auto">
          <section class="flex justify-between">
            <div class="flex flex-col gap-1">
              <section>#XM9141</section>
              <section>Graphic Design</section>
            </div>
            <div class="flex flex-col gap-1">
              <section>19 Union Terrace</section>
              <section>London</section>
              <section>
                E1 3EZ
              </section>
              <section>
                United Kingdom
              </section>
            </div>
          </section>

          <section class="flex flex-col gap-2">
            <section class="flex justify-start gap-32">
              <div class="flex flex-col">
                <section>Invoice Date</section>
                <section>21 Aug 2021</section>
              </div>

              <div class="flex flex-col">
                <section>Bill To</section>
                <section>Alex Grim</section>
              </div>

              <div class="flex flex-col">
                <section>Sent to</section>
                <section>alexgrim@mail.com</section>
              </div>
            </section>

            <section class="flex justify-start gap-28">
              <div class="flex flex-col gap-3">
                <section>Payment Due</section>
                <section>20 Sep 2021</section>
              </div>
              <div class="flex flex-col gap-1">
                <section>84 Church Way</section>
                <section>
                  Bradford
                </section>
                <section>
                  BD1 9PB
                </section>
                <section>
                  United Kingdom
                </section>
              </div>
            </section>
          </section>

          <div class="bg-[#F9FAFE] rounded-lg pt-10 overflow-hidden">
            <div class="border border-red-400 w-[92%] mx-auto flex gap-16 mb-10">
              <section class="w-[35%] flex flex-col gap-12">
                <div>Item Name</div>
                <div>Banner Design</div>
                <div>Email Design</div>
              </section>

              <section class="flex flex-col items-center gap-12">
                <div>QTY</div>
                <div>1</div>
                <div>2</div>
              </section>

              <section class="flex flex-col items-end gap-12">
                <div>Price</div>
                <div>£ 156.00</div>
                <div>£ 200.00</div>
              </section>

              <section class="flex flex-col items-end gap-12">
                <div>Total</div>
                <div>£ 156.00</div>
                <div>£ 400.00</div>
              </section>
            </div>

            <div class="bg-[#373B53] py-10">
              <div class="w-[92%] mx-auto flex justify-between text-[#FFFFFF]">
                <section>Amount Due</section>
                <section>£ 556.00</section>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
