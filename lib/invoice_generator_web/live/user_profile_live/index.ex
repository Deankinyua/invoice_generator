defmodule InvoiceGeneratorWeb.Event.Step do
  @moduledoc """

  Describe a step in the multi-step form and where it can go.
  """

  defstruct [:name, :prev, :next]
end

defmodule InvoiceGeneratorWeb.UserProfileLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Profile
  alias InvoiceGenerator.Profile.UserProfile

  alias InvoiceGeneratorWeb.Event.Step

  @steps [
    %Step{name: "picture", prev: nil, next: "details"},
    %Step{name: "details", prev: "picture", next: nil}
  ]

  @impl true

  def render(assigns) do
    ~H"""
    <div>
      <div class={unless @progress.name == "picture", do: "hidden"}>
        <.live_component
          module={InvoiceGeneratorWeb.Picture.FormComponent}
          id="user_picture"
          current_user={@current_user.id}
          action={@live_action}
          user_profile={@user_profile}
        />
      </div>

      <div class={unless @progress.name == "details", do: "hidden"}>
        <.live_component
          module={InvoiceGeneratorWeb.UserProfileLive.FormComponent}
          id="user_details"
          current_user={@current_user.id}
          action={@live_action}
          user_profile={@user_profile}
        />
      </div>

      <Button.button size="xl" phx-click={JS.patch(~p"/profiles/new")}>
        <:icon>
          <.icon name="hero-plus" />
        </:icon>
        Profile Setup
      </Button.button>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    first_step = Enum.at(@steps, 0)

    user_profile = %UserProfile{}

    dbg(first_step)

    socket =
      socket
      |> assign(live_action: :new)
      |> assign(progress: first_step)
      |> assign(user_profile: user_profile)

    {:ok, stream(socket, :profiles, [])}
  end

  @impl true
  def handle_info(:success_upload, socket) do
    second_step = Enum.at(@steps, 1)

    IO.puts("video is in the process")

    {:noreply,
     socket
     |> assign(progress: second_step)}
  end

  @impl true
  def handle_info(:back, socket) do
    first_step = Enum.at(@steps, 0)

    IO.puts("going back")

    {:noreply,
     socket
     |> assign(progress: first_step)}
  end
end
