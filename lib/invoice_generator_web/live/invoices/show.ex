defmodule InvoiceGeneratorWeb.InvoiceLive.Show do
  @moduledoc """
  Shows an Individual Invoice.
  """

  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGeneratorWeb.InvoiceLive.DeadView.InvoiceHelper
  alias InvoiceGeneratorWeb.InvoiceLive.View.InvoiceComponent
  alias InvoiceGenerator.{Records, Repo}

  alias InvoiceGenerator.Records.Invoice

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
        <Layout.flex flex_direction="col" justify_content="between" class="gap-5">
          <div class="w-full flex gap-6 items-center rounded-lg mt-8">
            <section>
              <img src={~p"/images/invoices/back_arrow2.svg"} alt="Back Arrow 2" />
            </section>
            <section class="league-spartan-bold text-[#0C0E16]">Go back</section>
          </div>

          <div class="w-full bg-[#FFFFFF] rounded-lg py-8 mt-4">
            <div class="flex justify-between gap-10 items-center w-[90%] mx-auto">
              <div class="text-sm league-spartan-medium text-[#858BB2]">Status</div>
              <div>
                <InvoiceHelper.invoice_state_button invoice_state={:Pending} />
              </div>
            </div>
          </div>
          <section class="w-full bg-[#FFFFFF] rounded-lg">
            <div class="flex flex-col gap-10 w-[90%] mx-auto my-6 text-sm text-[#7E88C3]">
              <div>
                <section class="league-spartan-bold text-[#858BB2]">
                  #<span class="text-[#0C0E16]">{InvoiceComponent.first_six_letters("XM9141")}</span>
                </section>

                <section class="league-spartan-medium">
                  Graphic Design
                </section>
              </div>
              <div class="league-spartan-medium">
                <p>
                  19 Union Terrace
                </p>
                <p>
                  London
                </p>
                <p>
                  E1 3EZ
                </p>
                <p>
                  United Kingdom
                </p>
              </div>
              <div class="flex flex-col gap-3 league-spartan-medium">
                <div class="flex gap-16">
                  <section>
                    Invoice Date
                  </section>
                  <section>Bill To</section>
                </div>
                <div class="flex gap-12 text-[#0C0E16] league-spartan-bold text-base">
                  <section>21 Aug 2021</section>
                  <section>Alex Grim</section>
                </div>

                <div class="flex gap-12">
                  <section class="flex flex-col gap-2">
                    <div class="mt-6">
                      Payment Due
                    </div>
                    <div class="text-[#0C0E16] league-spartan-bold text-base">
                      20 Sep 2021
                    </div>
                  </section>
                  <section>
                    <p>
                      84 Church Way
                    </p>
                    <p>
                      Bradford
                    </p>
                    <p>
                      BD1 9PB
                    </p>
                    <p>
                      United Kingdom
                    </p>
                  </section>
                </div>
              </div>

              <div class="flex flex-col gap-3">
                <section class="league-spartan-medium">Sent to</section>
                <section class="text-base league-spartan-bold text-[#0C0E16]">
                  alexgrim@mail.com
                </section>
              </div>

              <div class="rounded-lg bg-[#F9FAFE] overflow-hidden">
                <div class="w-[85%] mx-auto my-6 flex flex-col gap-4">
                  <section class="flex items-center justify-between gap-6">
                    <div class="flex flex-col gap-2
    ">
                      <section class="league-spartan-bold text-base text-[#0C0E16]">
                        Banner Design
                      </section>
                      <section class="league-spartan-medium">
                        1 x £ 156.00
                      </section>
                    </div>
                    <div class="league-spartan-bold text-base text-[#0C0E16]">
                      £ 156.00
                    </div>
                  </section>

                  <section class="flex items-center justify-between gap-6">
                    <div class="flex flex-col gap-2
    ">
                      <section class="league-spartan-bold text-base text-[#0C0E16]">
                        Banner Design
                      </section>
                      <section class="league-spartan-medium">
                        1 x £ 156.00
                      </section>
                    </div>
                    <div class="league-spartan-bold text-base text-[#0C0E16]">
                      £ 156.00
                    </div>
                  </section>
                </div>

                <div class="bg-[#373B53] py-8 flex justify-center items-center gap-20 text-[#FFFFFF]">
                  <section class="league-spartan-medium">
                    Grand Total
                  </section>
                  <section class="text-2xl league-spartan-bold">
                    £ 556.00
                  </section>
                </div>
              </div>
            </div>
          </section>
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
  def handle_params(%{"id" => id}, _, socket) do
    invoice = Records.get_invoice!(id)

    dbg(invoice)

    {:noreply, socket}
  end
end
