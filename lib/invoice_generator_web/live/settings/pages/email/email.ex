defmodule InvoiceGeneratorWeb.SettingsLive.EmailNotifications do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Helpers, Notifications, Notifications.Notification, Repo}

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
            "active_tab" => "notifications",
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
            </Layout.flex>

            <p class="league-spartan-medium my-4 text-xl">
              Edit Notifications Preferences
            </p>
            <p class="league-spartan-medium my-4">
              I’d like to receive:
            </p>

            <div>
              <.form for={@form} phx-submit="change_notifications">
                <.input
                  field={@form[:product_updates]}
                  type="checkbox"
                  label="Newsletter and product updates"
                  label_class="league-spartan-regular"
                />
                <.input
                  field={@form[:sign_in_notification]}
                  type="checkbox"
                  label="Sign in notification"
                  label_class="league-spartan-regular"
                />
                <.input
                  field={@form[:payment_reminders]}
                  type="checkbox"
                  label="Due payment reminders"
                  label_class="league-spartan-regular"
                />

                <button
                  type="submit"
                  class="bg-[#7C5DFA] text-[#FFFFFF] league-spartan-semibold rounded-full px-6 py-3 my-3"
                  phx-disable-with="Saving..."
                >
                  Save Changes
                </button>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    user_id = user.id

    profile_url = Helpers.get_profile_url(user_id)

    {notification, notification_changeset} = get_form_source(user_id)

    form = to_form(notification_changeset, as: "notifications")

    {:ok,
     socket
     |> assign(profile_url: profile_url)
     |> assign(form: form)
     |> assign(notification_settings: notification)}
  end

  defp get_form_source(user_id) do
    case Notifications.get_notification_by_user_id(user_id) do
      nil ->
        notification = %Notification{user_id: user_id, product_updates: true}

        changeset = Notifications.change_notification(notification)

        {notification, changeset}

      user_notification_settings ->
        changeset = Notifications.change_notification(user_notification_settings)

        {user_notification_settings, changeset}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("change_notifications", %{"notifications" => notification_params}, socket) do
    user_id = socket.assigns.current_user.id

    notification_settings = socket.assigns.notification_settings

    changeset = Notifications.change_notification(notification_settings, notification_params)

    case submit_details(user_id, changeset) do
      :success ->
        {:noreply,
         socket
         |> put_flash(:info, "Your notification settings were updated successfully")}

      :failure ->
        {:noreply,
         put_flash(socket, :error, "An error occurred while updating your notification settings")}
    end
  end

  defp submit_details(user_id, changeset) do
    case Notifications.get_notification_by_user_id(user_id) do
      nil ->
        case Repo.insert(changeset) do
          {:ok, _notification} ->
            :success

          {:error, _changeset} ->
            :failure
        end

      _user_notification_settings ->
        case Repo.update(changeset) do
          {:ok, _updated_record} ->
            :success

          {:error, _changeset} ->
            :failure
        end
    end
  end
end
