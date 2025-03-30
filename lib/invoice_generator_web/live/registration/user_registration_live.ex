defmodule InvoiceGeneratorWeb.UserRegistrationLive do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Accounts, Helpers}
  alias InvoiceGenerator.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="my-6 bg-[#FFFFFF]">
      <%= if @confirm do %>
        <div class="">
          <.live_component
            module={InvoiceGeneratorWeb.ConfirmationFeedback.Component}
            id="feedback_confirmation"
            email={@email}
          />
        </div>
      <% else %>
        <Layout.flex flex_direction="col" justify_content="center" class="">
          <Layout.flex
            flex_direction="col"
            align_items="start"
            class="grow w-[90%] max-w-4xl"
          >
            <div class="w-full text-[2rem] league-spartan-bold">
              Create an account
            </div>

            <div class="w-full league-spartan-regular">
              Begin creating invoices for free!
            </div>

            <div class="w-full">
              <.form
                for={@form}
                id="registration_form"
                phx-submit="save"
                phx-change="validate"
                phx-trigger-action={@trigger_submit}
                action={~p"/users/log_in?_action=registered"}
                method="post"
              >
                <div class="flex flex-col gap-5">
                  <.input
                    field={@form[:name]}
                    type="text"
                    placeholder="Enter Your Name"
                    class="league-spartan-extralight"
                  />
                  <.input
                    field={@form[:username]}
                    type="text"
                    placeholder="Enter Your Username"
                    class="league-spartan-extralight"
                  />
                  <.input
                    field={@form[:email]}
                    type="email"
                    placeholder="Enter Your Email"
                    class="league-spartan-extralight"
                  />

                  <div class="mt-2">
                    <Input.text_input
                      id="password"
                      name="user[password]"
                      placeholder="Enter Your Password"
                      class="league-spartan-extralight"
                      type="password"
                      field={@form[:password]}
                      value={@form[:password].value}
                    />
                  </div>
                </div>

                <div class="mt-10">
                  <.live_component
                    module={InvoiceGeneratorWeb.Password.Validation.Component}
                    id="password_validation_component"
                    form_errors={@form_errors}
                  />
                </div>

                <button
                  type="submit"
                  class="bg-[#7C5DFA] text-[#FFFFFF] league-spartan-bold rounded-md w-full text-xl px-6 py-3 my-8"
                  phx-disable-with="Creating account..."
                >
                  Sign Up
                </button>
              </.form>
            </div>

            <Layout.flex
              class="space-x-2 underline cursor-pointer decoration-2"
              justify_content="start"
            >
              <p class="text-[#000000CC] league-spartan-medium">
                Already have an account?
              </p>

              <a href="/users/log_in" class="cursor-pointer decoration-2 text-[#7C5DFA] league-spartan-medium">
                <p>
                  Login
                </p>
              </a>
            </Layout.flex>
          </Layout.flex>
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
      |> assign(email: "")
      |> assign_form(changeset)
      |> assign(form_errors: Helpers.initial_errors())

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
         |> assign(confirm: true)
         |> assign(email: user.email)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => %{"password" => password} = user_params}, socket) do
    changeset = Accounts.change_user_registration_sign_up(%User{}, user_params)
    errors = Helpers.get_map_of_errors(changeset.errors)

    socket =
      if password == "" do
        socket
        |> assign(form_errors: Helpers.initial_errors())
      else
        socket
        |> assign(form_errors: errors)
      end

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
