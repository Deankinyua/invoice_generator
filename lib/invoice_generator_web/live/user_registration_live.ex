defmodule InvoiceGeneratorWeb.UserRegistrationLive do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Accounts
  alias InvoiceGenerator.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <%= if @confirm do %>
        <h1 class="sm:text-center sm:text-xl">
          where we place the confirmation message
        </h1>
      <% else %>
        <.header class="text-center">
          Register for an account
          <:subtitle>
            Already registered?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
              Log in
            </.link>
            to your account now.
          </:subtitle>
        </.header>

        <.form
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/users/log_in?_action=registered"}
          method="post"
        >
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input
            field={@form[:name]}
            type="text"
            label="Name"
            placeholder="Enter Your Name"
            required
          />
          <.input
            field={@form[:username]}
            type="text"
            label="Username"
            placeholder="Enter Your Username"
            required
          />
          <.input
            field={@form[:email]}
            type="email"
            label="Email"
            placeholder="Enter Your Email"
            required
          />

          <Layout.col class="space-y-1.5">
            <label for="password">
              <Text.text class="text-tremor-content font-extrabold text-black">
                Password
              </Text.text>
            </label>

            <Input.text_input
              id="password"
              name="user[password]"
              placeholder="Enter Your Password"
              type="password"
              field={@form[:password]}
              value={@form[:password].value}
            />
          </Layout.col>

          <Button.button type="submit" size="xl" class="mt-4" phx-disable-with="Creating account...">
            Sign Up
          </Button.button>
        </.form>

        <Layout.flex class="space-x-2 underline cursor-pointer decoration-2" justify_content="start">
          <Text.subtitle color="gray">
            Already have an account?
          </Text.subtitle>

          <a href="/users/log_in" class="cursor-pointer decoration-2 text-blue-400">
            <Text.subtitle color="blue">
              Login
            </Text.subtitle>
          </a>
        </Layout.flex>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(confirm: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        _changeset = Accounts.change_user_registration(user)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         #  |> assign_form(changeset)
         |> assign(confirm: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
