defmodule InvoiceGeneratorWeb.SettingsLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Profile

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

      {live_render(@socket, InvoiceGeneratorWeb.Settings.LiveDrawer,
        session: %{
          "active_tab" => "personal",
          "user" => "user?email=#{@current_user.email}"
        },
        id: "settings_live_drawer",
        sticky: true
      )}

      <div class="border border-blue-400 mx-4">Personal</div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
