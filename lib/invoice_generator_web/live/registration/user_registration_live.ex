defmodule InvoiceGeneratorWeb.UserRegistrationLive do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Accounts, Helpers}
  alias InvoiceGenerator.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="bg-[#FFFFFF]">
      <%= if @confirm do %>
        <div class="">
          <.live_component
            module={InvoiceGeneratorWeb.ConfirmationFeedback.Component}
            id="feedback_confirmation"
            email={@email}
          />
        </div>
      <% else %>
        <div class="flex justify-center lg:h-screen lg:overflow-hidden lg:justify-between">
          <div class="w-[48%] hidden lg:block">
            <img src={~p"/images/home/welcome_paint.svg"} class="w-full h-full object-cover" />
          </div>

          <Layout.flex flex_direction="col" justify_content="center" class="lg:w-[52%]">
            <Layout.flex
              flex_direction="col"
              align_items="start"
              class="grow w-[84%] lg:w-[80%] xl:w-[70%] max-w-3xl"
            >
              <div class="hidden lg:flex flex-row justify-center lg:mb-6 items-center gap-6 pt-10 w-full">
                <section class="w-20 md:w-24 lg:w-20">
                  <img src={~p"/images/mobilelogo.svg"} class="w-full h-full object-cover" />
                </section>
                <section class="font-semibold text-[#7c5dfa] text-[3.5rem] league-spartan-semibold md:text-9xl lg:text-[3.5rem]">
                  Invoice
                </section>
              </div>

              <div class="w-full text-[2rem] league-spartan-semibold sm:text-6xl lg:text-center lg:text-[2.5rem] mt-10 lg:mt-0 lg:mb-4">
                Create an account
              </div>
              <div class="w-full league-spartan-regular sm:text-[2rem] lg:hidden">
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
                  <div class="lg:flex flex-col gap-5">
                    <div class="flex flex-col justify-start gap-4 lg:flex-row lg:gap-10 lg:items-center">
                      <div class="flex flex-col">
                        <label for="name" class="hidden lg:block">
                          <p class="league-spartan-semibold">
                            Name
                          </p>
                        </label>
                        <.input
                          id="name"
                          field={@form[:name]}
                          type="text"
                          placeholder="Enter Your Name"
                          phx-debounce="1000"
                          class="hide-placeholder league-spartan-extralight max-w-xl sm:text-xl"
                        />
                      </div>
                      <div class="flex flex-col">
                        <label for="username" class="hidden lg:block">
                          <p class="league-spartan-semibold">
                            Username
                          </p>
                        </label>
                        <.input
                          id="username"
                          field={@form[:username]}
                          type="text"
                          placeholder="Enter Your Username"
                          phx-debounce="1000"
                          class="hide-placeholder league-spartan-extralight max-w-xl sm:text-xl"
                        />
                      </div>
                    </div>
                    <div class="flex flex-col mt-4 lg:mt-0">
                      <label for="email" class="hidden lg:block">
                        <p class="league-spartan-semibold">
                          Email
                        </p>
                      </label>
                      <.input
                        id="email"
                        field={@form[:email]}
                        type="email"
                        placeholder="name@example.com"
                        phx-debounce="1000"
                        class="league-spartan-extralight max-w-xl sm:text-xl"
                      />
                    </div>
                    <div class="flex flex-col mt-6 lg:mt-0">
                      <label for="password_2" class="hidden lg:block">
                        <p class="league-spartan-semibold">
                          Password
                        </p>
                      </label>
                      <Input.text_input
                        id="password_2"
                        name="user[password]"
                        placeholder="Enter Your Password"
                        class="league-spartan-extralight max-w-xl border-[#00000066]"
                        type="password"
                        field={@form[:password]}
                        value={@form[:password].value}
                      />
                    </div>
                  </div>
                  <div class="mt-4">
                    <.live_component
                      module={InvoiceGeneratorWeb.Password.Validation.Component}
                      id="password_validation_component"
                      form_errors={@form_errors}
                    />
                  </div>
                  <button
                    type="submit"
                    class="bg-[#7C5DFA] text-[#FFFFFF] league-spartan-bold rounded-md w-full max-w-xl text-xl px-6 py-3 my-8 lg:my-2"
                    phx-disable-with="Creating account..."
                  >
                    Sign Up
                  </button>
                </.form>
              </div>
              <Layout.flex
                class="space-x-2 underline cursor-pointer decoration-2 pb-6"
                justify_content="start"
              >
                <p class="text-xl text-[#000000CC] league-spartan-medium">
                  Already have an account?
                </p>
                <a
                  href="/users/log_in"
                  class="cursor-pointer decoration-2 text-[#7C5DFA] text-xl league-spartan-medium"
                >
                  <p>
                    Login
                  </p>
                </a>
              </Layout.flex>
            </Layout.flex>
          </Layout.flex>
        </div>
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
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_form(changeset)}
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
