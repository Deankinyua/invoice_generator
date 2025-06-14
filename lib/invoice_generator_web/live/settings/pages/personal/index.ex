defmodule InvoiceGeneratorWeb.SettingsLive.Index do
  use InvoiceGeneratorWeb, :live_view

  import Ecto.Changeset

  alias InvoiceGenerator.{Accounts, Helpers, Profile, Repo}

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="w-full h-full bg-[#F8F8F8]">
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?email=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}

      <div class="min-h-screen mx-2 mx-auto max-w-4xl sm:w-[60%] sm:py-6">
        {live_render(@socket, InvoiceGeneratorWeb.Settings.LiveDrawer,
          session: %{
            "active_tab" => "personal",
            "user" => "user?email=#{@current_user.email}"
          },
          id: "settings_live_drawer",
          sticky: true
        )}

        <div class="mx-4 py-10 bg-[#FFFFFF]">
          <div class="w-[90%] mx-auto">
            <Layout.flex flex_direction="col" align_items="start" class="gap-4">
              <div class="">
                <.live_component
                  module={InvoiceGeneratorWeb.Profile.ActualPicture}
                  id="actual_picture_live_component"
                  profile_url={@profile_url}
                  name={@current_user.name}
                />
              </div>

              <Layout.flex flex_direction="row">
                <section>
                  <.live_component
                    module={InvoiceGeneratorWeb.SettingsLive.UpdateProfilePicture}
                    id="settings_update_profile_picture"
                    user_id={@current_user.id}
                  />
                </section>
              </Layout.flex>
            </Layout.flex>
            <p class="my-4 text-xl league-spartan-medium text-[#0C0E16]">
              Edit Profile Information
            </p>

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
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    {:ok, assign(socket, profile_url: Helpers.get_profile_url(user_id))}
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:update_profile_picture, details},
        socket
      ) do
    user_id = socket.assigns.current_user.id

    user = Helpers.get_user(user_id)

    _result =
      case Map.get(user.picture, :original_filename) do
        nil ->
          :ok

        filename ->
          delete_profile_picture(filename)
      end

    changeset = change(user, %{picture: details})
    Repo.update(changeset)

    {
      :noreply,
      redirect(socket, to: "/personaldetails")
    }
  end

  def handle_info(
        {:valid_personal_details, changeset},
        socket
      ) do
    personal_details = changeset.changes

    {:noreply,
     socket
     |> assign(personal_details: personal_details)}
  end

  def handle_info(
        :update_personal_info,
        socket
      ) do
    case Map.get(socket.assigns, :personal_details) do
      nil ->
        :ok

      details ->
        current_user = socket.assigns.current_user

        user_changeset = Accounts.change_user_registration(current_user, details)
        Repo.update(user_changeset)
    end

    {:noreply,
     socket
     |> put_flash(:info, "Your profile has been updated successfully")
     |> redirect(to: "/personaldetails")}
  end

  @impl Phoenix.LiveView
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"user_id" => user_id}, socket) do
    user_profile = Helpers.get_user(user_id)

    case Map.get(user_profile.picture, :original_filename) do
      nil ->
        {:noreply, socket}

      filename ->
        new_picture_details = %{original_filename: "none", filename: "none"}

        profile_changeset =
          Profile.change_user_profile(user_profile, %{picture: new_picture_details})

        Repo.update(profile_changeset)
        delete_profile_picture(filename)

        {:noreply, redirect(socket, to: "/personaldetails")}
    end
  end

  defp delete_profile_picture(file_name) do
    file_name = "photo/" <> file_name

    _result =
      "invoicegenerator"
      |> ExAws.S3.delete_object(file_name)
      |> ExAws.request()
  end
end
