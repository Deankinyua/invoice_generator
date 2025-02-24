defmodule InvoiceGeneratorWeb.SettingsLive.Index do
  use InvoiceGeneratorWeb, :live_view

  require Logger
  alias InvoiceGenerator.{Helpers}

  alias Ecto.Changeset
  alias InvoiceGenerator.Repo

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
        <Layout.flex flex_direction="col">
          <.live_component
            module={InvoiceGeneratorWeb.Profile.ActualPicture}
            id="actual_picture_live_component"
            profile_url={@profile_url}
            name={@current_user.name}
          />

          <Layout.flex flex_direction="row">
            <section>
              <.live_component
                module={InvoiceGeneratorWeb.SettingsLive.UpdateProfilePicture}
                id="settings_update_profile_picture"
                profile_url={@profile_url}
              />
            </section>
          </Layout.flex>
        </Layout.flex>

        <.live_component
          module={InvoiceGeneratorWeb.SettingsLive.PersonalDetails}
          id="settings_personal_details"
          current_user={@current_user}
        />

        <.live_component
          module={InvoiceGeneratorWeb.SettingsLive.BusinessAddressDetails}
          id="settings_business_address_details"
          current_user={@current_user.id}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    profile_url = Helpers.get_profile_url(user_id)

    {:ok,
     socket
     |> assign(profile_url: profile_url)}
  end

  @impl true
  def handle_info(
        {:update_profile_picture, details},
        socket
      ) do
    user_id = socket.assigns.current_user.id

    user = Helpers.get_user(user_id)

    previous_picture = user.picture.original_filename

    delete_previous_profile_picture(previous_picture)

    changeset = Changeset.change(user, %{picture: details})
    Repo.update(changeset)

    {
      :noreply,
      socket
      |> redirect(to: "/personaldetails")
    }
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp delete_previous_profile_picture(file_name) do
    file_name = "photo/" <> file_name

    _result =
      ExAws.S3.delete_object("invoicegenerator", file_name)
      |> ExAws.request()
  end
end
