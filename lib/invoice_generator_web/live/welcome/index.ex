defmodule InvoiceGeneratorWeb.WelcomeLive.Index do
  @moduledoc """
  The welcome to our Application.
  """

  use InvoiceGeneratorWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center border border-red-400">
      <section class="flex flex-col items-center justify-start gap-6 border border-red-400 h-[90vh] py-8">
        <div class="flex flex-row justify-center items-center gap-6 border border-blue-400 w-full">
          <section><img src="images/mobilelogo.svg" /></section>
          <section class="font-semibold text-[#7c5dfa] text-5xl">Invoice</section>
        </div>
        <div class="w-full flex flex-col items-center border border-red-400 mb-20 text-2xl font-semibold">
          Sign in to Invoice
        </div>
        <div class="flex flex-row justify-center items-center gap-6 w-[75%] mb-10 border border-red-400">
          <section class="border border-blue-400 w-6">
            <img class="object-cover" src="images/googlesmall.svg" />
          </section>
          <section class="text-lg border border-blue-400">Sign in with Google</section>
        </div>
        <.link
          class="flex flex-row justify-center items-center gap-6 w-full mb-14 w-[75%]"
          patch={~p"/users/register"}
        >
          <section class="border border-blue-400 w-6">
            <img class="object-cover" width="60" src="images/email.svg" />
          </section>
          <section class="text-lg">Continue with email</section>
        </.link>

        <div class="w-[68%] border border-green-400">
          By creating an account, you agree to Invoice company's
          <span class="font-bold">Terms of use</span>
          and <span class="font-bold">Privacy Policy</span>
        </div>
      </section>
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
