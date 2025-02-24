defmodule InvoiceGeneratorWeb.SettingsLive.Password do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Accounts

  alias InvoiceGenerator.{Helpers}
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
          "active_tab" => "password",
          "user" => "user?email=#{@current_user.email}"
        },
        id: "settings_live_drawer",
        sticky: true
      )}

      <div class="border border-blue-400 mx-4 py-20">
        <Layout.flex flex_direction="col" align_items="start" class="gap-4 border border-red-400">
          <div class="border border-red-400">
            <.live_component
              module={InvoiceGeneratorWeb.Profile.ActualPicture}
              id="actual_picture_live_component"
              profile_url={@profile_url}
              name={@current_user.name}
            />
          </div>
        </Layout.flex>

        <Text.title class="my-4">
          Change Password
        </Text.title>

        <.simple_form for={@form} phx-submit="reset_password" phx-change="validate">
          <.input field={@form[:old_password]} type="text" label="Old password" />
          <.input field={@form[:password]} type="text" label="New password" />
          <:actions>
            <.button phx-disable-with="Resetting..." class="w-full">Save Changes</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    user_id = user.id

    profile_url = Helpers.get_profile_url(user_id)

    changeset = Accounts.change_user_password_with_old_password(user)

    form = to_form(changeset, as: "password")

    dbg(form)

    {:ok,
     socket
     |> assign(profile_url: profile_url)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"password" => _password_params}, socket) do
    # changeset = Accounts.change_user_password(socket.assigns.user, password_params)

    # dbg(password_params)

    {:noreply, socket}
    # {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  @impl true
  def handle_event(
        "reset_password",
        %{"password" => %{"old_password" => old_password, "password" => new_password}},
        socket
      ) do
    # changeset = Accounts.change_user_password(socket.assigns.user, password_params)

    user = socket.assigns.current_user

    case Accounts.get_user_if_valid_password(user, old_password) do
      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "The old password you entered is incorrect")}

      _user ->




        {:noreply,
         socket
         |> put_flash(:info, "You entered the correct old password")}
    end

  end
end
