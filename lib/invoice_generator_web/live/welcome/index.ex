defmodule InvoiceGeneratorWeb.WelcomeLive.Index do
  @moduledoc """
  The welcome to our Application.
  """

  use InvoiceGeneratorWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex justify-center h-screen overflow-hidden lg:justify-between">
      <div class="w-[48%] hidden lg:block">
        <img src={~p"/images/home/welcome_paint.svg"} class="w-full h-full object-cover" />
      </div>

      <div class="w-[52%] flex flex-col items-center grow">
        <section class="w-full flex flex-col items-center justify-start gap-2 h-[90vh] py-8">
          <div class="flex flex-row justify-center items-center gap-6 pt-10 w-full lg:mb-24">
            <section class="w-20 md:w-24 lg:w-20">
              <img src={~p"/images/mobilelogo.svg"} class="w-full h-full object-cover" />
            </section>
            <section class="font-semibold text-[#7c5dfa] text-[3.5rem] league-spartan-semibold md:text-9xl lg:text-[3.5rem]">
              Invoice
            </section>
          </div>
          <div class="w-full flex flex-col items-center mb-20 lg:mb-10 text-2xl">
            <div class="text-[2rem] league-spartan-medium md:text-5xl lg:text-[2.5rem]">
              Sign in to Invoice
            </div>
          </div>
          <.link
            class="flex flex-row justify-center items-center gap-6 w-[75%] max-w-[30.31rem] mb-6 border rounded-full py-2 md:py-5 lg:mb-4 lg:py-2"
            patch={~p"/"}
          >
            <section class="w-6 md:w-8 lg:w-6">
              <img class="w-full h-full object-cover" src={~p"/images/googlesmall.svg"} />
            </section>
            <div class="text-xl league-spartan-regular md:text-4xl lg:text-xl">
              Sign in with Google
            </div>
          </.link>
          <.link
            class="flex flex-row justify-center items-center gap-6 w-[75%] max-w-[30.31rem] mb-10 py-2 border rounded-full md:py-6 lg:py-2"
            href={~p"/users/log_in"}
          >
            <section class="w-6 md:w-8 lg:w-6">
              <img class="w-full h-full object-cover" src={~p"/images/email.svg"} />
            </section>
            <div class="text-xl league-spartan-regular md:text-4xl lg:text-xl">
              Continue with email
            </div>
          </.link>
          <div class="w-[68%] league-spartan-regular text-center text-[#888EB0]">
            <p class="md:text-[2rem] lg:text-base">By creating an account, you agree to</p>
            <p class="mt-1 md:text-[2rem] lg:text-base">Invoice company's</p>
            <p class="mt-1">
              <span class="league-spartan-semibold md:text-xl lg:text-base">Terms of use</span>
              <span class="md:text-xl lg:text-base">and</span>
              <span class="league-spartan-semibold md:text-xl lg:text-base">Privacy Policy.</span>
            </p>

            <p class="hidden lg:block mt-6 league-spartan-regular text-xl">
              Don’t have an account?
              <span class="league-spartan-regular text-[#7C5DFA]">
                <.link href={~p"/users/register"}>
                  Sign Up
                </.link>
              </span>
            </p>
          </div>
        </section>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
