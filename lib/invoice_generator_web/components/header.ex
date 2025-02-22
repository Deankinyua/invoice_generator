defmodule InvoiceGeneratorWeb.Header do
  @moduledoc """
  Renders the header as a child liveview
  """
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Accounts

  @impl true
  def mount(_params, session, socket) do
    %{"user" => "user?id=" <> email, "image_url" => "user?url=" <> profile_url} = session

    current_user = Accounts.get_user_by_email(email)

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:profile_url, profile_url)
      |> assign(:theme, "profile_url")
      |> assign(is_dark: false)

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_event("dark-mode", %{"dark" => value}, socket) do
    is_dark = change_theme(value)

    socket =
      socket
      |> assign(is_dark: is_dark)

    {:noreply, push_event(socket, "toggle-mode", %{})}
  end

  defp change_theme(value) do
    if value == false do
      true
    else
      false
    end
  end

  defp theme_icon(is_dark) do
    if is_dark == false do
      "images/header/moon.svg"
    else
      "images/header/light.svg"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex class="gap-6">
        <Layout.flex>
          <section>logo</section>
          <section>
            <.link phx-click={JS.push("dark-mode", value: %{dark: @is_dark})}>
              <img src={theme_icon(@is_dark)} alt="theme" />
            </.link>
          </section>
        </Layout.flex>

        <section class="w-[32%] border border-red-400">
          <div class="w-[60%] mx-auto rounded-full overflow-hidden">
            <img src={@profile_url} class="h-10 w-10 rounded-full object-cover object-center" />
          </div>
        </section>
      </Layout.flex>
    </div>
    """
  end
end
