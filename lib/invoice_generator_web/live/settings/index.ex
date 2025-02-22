defmodule InvoiceGeneratorWeb.SettingsLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Profile

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border border-red-400">
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?id=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
