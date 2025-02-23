defmodule InvoiceGeneratorWeb.SettingsLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Helpers, Profile}

  alias InvoiceGenerator.Profile.UserProfile

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

      <div class="border border-blue-400 mx-4 py-20">
        <.live_component
          module={InvoiceGeneratorWeb.SettingsLive.PersonalDetails}
          id="settings_personal_address_details"
          current_user={@current_user}
        />

        <.live_component
          module={InvoiceGeneratorWeb.SettingsLive.BusinessDetails}
          id="settings_business_address_details"
          current_user={@current_user.id}
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
  def handle_info({:valid_personal_details, changeset}, socket) do
    dbg(changeset)
    # case submit_details(socket, changeset) do
    #   {:ok, _record} ->
    #     {:noreply,
    #      socket
    #      |> put_flash(:info, "User profile created successfully")
    #      |> redirect(to: ~p"/home")}

    #   {:error, _changeset} ->
    #     {:noreply,
    #      socket
    #      |> put_flash(:error, "You have already completed your profile!")
    #      |> redirect(to: ~p"/home")}
    # end
  end
end
