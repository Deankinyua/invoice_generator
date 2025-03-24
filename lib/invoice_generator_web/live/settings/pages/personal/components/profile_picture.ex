defmodule InvoiceGeneratorWeb.Profile.ActualPicture do
  use InvoiceGeneratorWeb, :live_component
  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex flex_direction="row" class="gap-2">
        <section class="h-20 w-20 sm:h-32 sm:w-32 rounded-full overflow-hidden ">
          <img src={@profile_url} class="h-80 w-80 rounded-full object-cover object-center" />
        </section>
        <section class="league-spartan-semibold text-[#0C0E16] text-base">
          {@name} / Profile Information
        </section>
      </Layout.flex>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end

defmodule InvoiceGeneratorWeb.SettingsLive.UpdateProfilePicture do
  use InvoiceGeneratorWeb, :live_component
  require Logger
  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <section>
      <.form for={@form} phx-target={@myself} phx-change="check">
        <button
          type="button"
          class="border border-[#DFE3FA] league-spartan-semibold rounded-full px-6 py-2"
        >
          <fieldset>
            <.live_file_input type="file" upload={@uploads.photo} class="hidden pointer-events-none" />
          </fieldset>

          <.droptarget
            for={@uploads.photo.ref}
            on_click={JS.dispatch("click", to: "##{@uploads.photo.ref}", bubbles: false)}
            drop_target_ref={@uploads.photo.ref}
          />
        </button>

        <button
          type="button"
          class="ml-3 bg-[#F9FAFE] rounded-full text-[#0C0E16] league-spartan-semibold rounded-full px-6 py-3"
          phx-click={JS.push("delete", value: %{user_id: @user_id})}
        >
          Delete
        </button>
      </.form>
    </section>
    """
  end

  @impl Phoenix.LiveComponent

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "profile_image_file",
        max_file_size: 80_000_000,
        progress: &handle_progress/3,
        auto_upload: true,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "photo")
        end
      )

    form = to_form(%{})

    #  current_user = assigns
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  defp handle_progress(:photo, entry, socket) do
    if entry.done? do
      _uploaded_file =
        consume_uploaded_entry(socket, entry, fn %{} = _meta ->
          filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)
          original_filename = entry.client_name
          details = %{filename: filename, original_filename: original_filename}

          send(self(), {:update_profile_picture, details})

          {:ok, entry}
        end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("check", _params, socket) do
    {:noreply, socket}
  end

  attr :on_click, JS, required: true
  attr :drop_target_ref, :string, required: true
  attr :for, :string, required: true

  @doc """
  Renders a drop target to upload files
  """

  def droptarget(assigns) do
    ~H"""
    <div phx-click={@on_click} phx-drop-target={@drop_target_ref} for={@for}>
      <Text.title>
        Upload a new photo
      </Text.title>
    </div>
    """
  end
end
