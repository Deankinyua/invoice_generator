defmodule InvoiceGeneratorWeb.SettingsLive.PersonalDetails do
  use InvoiceGeneratorWeb, :live_component
  alias InvoiceGenerator.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="league-spartan-medium">
      <.simple_form for={@form} phx-target={@myself} phx-change="validate">
        <Layout.col class="space-y-1.5">
          <label for="profile_name">
            <p class="text-sm text-[#7E88C3]">
              Name
            </p>
          </label>
          <.input field={@form[:name]} type="text" placeholder="Name..." />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label for="profile_username">
            <p class="text-sm text-[#7E88C3]">
              Username
            </p>
          </label>

          <.input field={@form[:username]} type="text" placeholder="Username..." />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <label for="profile_email">
            <p class="text-sm text-[#7E88C3]">
              Email
            </p>
          </label>

          <.input field={@form[:email]} type="text" placeholder="Email.." />
        </Layout.col>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    current_user = assigns.current_user

    form = to_form(Accounts.change_user_registration(current_user))

    #  current_user = assigns
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(socket.assigns.current_user, user_params)

    {:noreply, socket}

    case changeset.valid? do
      true ->
        send(self(), {:valid_personal_details, changeset})

        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
