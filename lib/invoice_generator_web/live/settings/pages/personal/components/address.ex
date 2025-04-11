defmodule InvoiceGeneratorWeb.SettingsLive.BusinessAddressDetails do
  use InvoiceGeneratorWeb, :live_component
  alias InvoiceGenerator.{Helpers, Profile, Repo}

  alias InvoiceGenerator.Profile.UserProfile

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="league-spartan-medium">
      <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <Layout.col class="space-y-1.5">
          <label for="profile_country">
            <p class="text-sm text-[#7E88C3]">
              Country
            </p>
          </label>

          <Select.search_select
            id="profile_country"
            name={@form[:country].name}
            placeholder="Select..."
            value={@form[:country].value}
            phx-update="ignore"
            required="true"
          >
            <:item :for={name <- @countries}>
              {name}
            </:item>
          </Select.search_select>
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label>
            <p class="text-sm text-[#7E88C3]">
              City
            </p>
          </label>

          <.input field={@form[:city]} type="text" placeholder="Street Address" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label>
            <p class="text-sm text-[#7E88C3]">
              Street Address
            </p>
          </label>

          <.input field={@form[:street]} type="text" placeholder="Street Address" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label>
            <p class="text-sm text-[#7E88C3]">
              Postal Code
            </p>
          </label>

          <.input field={@form[:postal_code]} type="text" placeholder="Postal Code" />
        </Layout.col>

        <button
          type="submit"
          class="bg-[#7C5DFA] text-[#FFFFFF] league-spartan-semibold rounded-full px-6 py-3"
          phx-disable-with="Saving..."
        >
          Save Changes
        </button>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    user_id = assigns.current_user

    countries = Helpers.countries()

    socket =
      socket
      |> assign(countries: countries)

    case Helpers.get_user(user_id) do
      nil ->
        user_profile = %UserProfile{user_id: user_id}

        form = to_form(Profile.change_user_profile(user_profile))

        {:ok,
         socket
         |> assign(form: form)
         |> assign(userprofile: user_profile)}

      user_profile ->
        form = to_form(Profile.change_user_profile(user_profile))

        {:ok,
         socket
         |> assign(form: form)
         |> assign(userprofile: user_profile)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.userprofile, user_profile_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.userprofile, user_profile_params)

    case changeset.valid? do
      true ->
        send(self(), :update_personal_info)
        Repo.update(changeset)

        {:noreply, socket}

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
