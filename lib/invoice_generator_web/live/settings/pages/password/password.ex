defmodule InvoiceGeneratorWeb.SettingsLive.Password do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Accounts, Helpers, Repo}

  @impl true
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
            "active_tab" => "password",
            "user" => "user?email=#{@current_user.email}"
          },
          id: "settings_live_drawer",
          sticky: true
        )}

        <div class="mx-4 py-10 bg-[#FFFFFF] league-spartan-medium">
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

            <p class="text-xl text-[#0C0E16]">
              Change Password
            </p>

            <.simple_form for={@form} phx-submit="reset_password" phx-change="validate" class="my-0">
              <.input
                field={@form[:old_password]}
                type="text"
                label="Old password"
                label_class="mt-0 text-[#7E88C3]"
              />
              <.input
                field={@form[:password]}
                type="nullify_errors"
                label="New password"
                label_class="mt-0 text-[#7E88C3]"
                autocomplete="off"
              />

              <.live_component
                module={InvoiceGeneratorWeb.Password.Validation.Component}
                id="password_validation_component"
                form_errors={@form_errors}
              />

              <:actions>
                <button
                  phx-disable-with="Resetting..."
                  class="w-[90%] mx-auto league-spartan-semibold bg-[#7C5DFA] text-[#FFFFFF] rounded-full px-5 py-3 mt-2"
                >
                  Save Changes
                </button>
              </:actions>
            </.simple_form>
          </div>
        </div>
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

    {:ok,
     socket
     |> assign(profile_url: profile_url)
     |> assign(form: form)
     |> assign(form_errors: Helpers.initial_errors())}
  end

  @impl true
  def handle_event(
        "validate",
        %{"password" => %{"old_password" => _old_password, "password" => new_password}},
        socket
      ) do
    changeset =
      Accounts.change_user_password_with_old_password(
        socket.assigns.current_user,
        %{"password" => new_password}
      )

    errors = Helpers.get_map_of_errors(changeset.errors)

    socket =
      if new_password == "" do
        socket
        |> assign(form_errors: Helpers.initial_errors())
      else
        socket
        |> assign(form_errors: errors)
      end

    {:noreply, assign(socket, form: to_form(changeset, action: :validate, as: "password"))}
  end

  @impl true
  def handle_event(
        "reset_password",
        %{"password" => %{"old_password" => old_password, "password" => new_password}},
        socket
      ) do
    user = socket.assigns.current_user

    changeset =
      Accounts.change_user_password_with_old_password(
        user,
        %{"password" => new_password}
      )

    case changeset.valid? do
      true ->
        case Accounts.get_user_if_valid_password(user, old_password) do
          :error ->
            {:noreply,
             socket
             |> put_flash(:error, "The old password you entered is incorrect")}

          _user ->
            changeset = Accounts.hash_password_before_insertion(changeset)

            Repo.update(changeset)

            {:noreply,
             socket
             |> put_flash(:info, "You updated your password successfully")
             |> redirect(to: "/password")}
        end

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate, as: "password"))}
    end
  end
end
