defmodule InvoiceGeneratorWeb.HomeLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.Profile

  @impl true

  def render(assigns) do
    ~H"""
    <div class="border border-red-400 m-4">
      <div>header section</div>
      <div>
        <div class="rounded-full border  overflow-hidden ">
          <img src={@profile_url} height="50" />
        </div>
        nav links
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    case get_user(user_id) do
      nil ->
        {:ok,
         socket
         |> assign(profile_url: "")}

      user ->
        base_url = "http://127.0.0.1:9000/invoicegenerator/photo/"

        user_profile_picture_url = base_url <> user.picture.original_filename

        dbg(user_profile_picture_url)

        {:ok,
         socket
         |> assign(profile_url: user_profile_picture_url)}
    end
  end

  defp get_user(user_id) do
    Profile.get_user_profile_by_user_id(user_id)
  end
end
