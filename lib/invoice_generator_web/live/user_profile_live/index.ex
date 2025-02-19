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

    dbg(first_step)

    socket =
      socket
      |> assign(live_action: :new)
      |> assign(progress: first_step)

    {:ok, stream(socket, :profiles, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User profile")
    |> assign(:user_profile, Profile.get_user_profile!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User profile")
    |> assign(:user_profile, %UserProfile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Profiles")
    |> assign(:user_profile, nil)
  end

  @impl true
  def handle_info(
        {InvoiceGeneratorWeb.UserProfileLive.FormComponent, {:saved, user_profile}},
        socket
      ) do
    {:noreply, stream_insert(socket, :profiles, user_profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_profile = Profile.get_user_profile!(id)
    {:ok, _} = Profile.delete_user_profile(user_profile)

    {:noreply, stream_delete(socket, :profiles, user_profile)}
  end
end
