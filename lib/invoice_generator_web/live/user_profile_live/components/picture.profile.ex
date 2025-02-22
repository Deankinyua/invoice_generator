defmodule InvoiceGeneratorWeb.Picture.FormComponent do
  use InvoiceGeneratorWeb, :live_component

  alias SimpleS3Upload

  alias InvoiceGenerator.Profile.Picture

  alias InvoiceGenerator.Profile
  @impl true
  def render(assigns) do
    ~H"""
    <section id="user_picture">
      <Layout.col>
        <Layout.col>
          <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
            <fieldset>
              <.live_file_input
                type="file"
                upload={@uploads.profile_photo}
                class="hidden pointer-events-none"
              />
            </fieldset>

            <.droptarget
              for={@uploads.profile_photo.ref}
              on_click={JS.dispatch("click", to: "##{@uploads.profile_photo.ref}", bubbles: false)}
              drop_target_ref={@uploads.profile_photo.ref}
            />

            <%= for entry <- @uploads.profile_photo.entries
    do %>
              <article class="upload-entry">
                <figure>
                  <.live_img_preview entry={entry} height="40" />
                </figure>

                <Layout.flex justify_content="start" align_items="center" class="space-x-4">
                  <Layout.flex flex_direction="col" align_items="start">
                    <Layout.flex class="space-x-4">
                      <Layout.flex class="" flex_direction="col" align_items="start">
                        <div class="w-full flex-1">
                          <Text.subtitle color="black" class="text-ellipsis">
                            {entry.client_name}
                          </Text.subtitle>
                        </div>
                      </Layout.flex>

                      <Button.button
                        class="mt-2 flex-shrink-0"
                        variant="secondary"
                        color="rose"
                        size="xs"
                        phx-click="cancel-upload"
                        phx-value-ref={entry.ref}
                        aria-label="cancel"
                        phx-target={@myself}
                      >
                        Cancel
                      </Button.button>
                    </Layout.flex>
                  </Layout.flex>
                </Layout.flex>

                <%= for err <- upload_errors(@uploads.profile_photo, entry) do %>
                  <p class="alert alert-danger">{error_to_string(err)}</p>
                <% end %>
              </article>
            <% end %>

            <Button.button phx-disable-with="Proceeding...">
              <.link phx-click={JS.push("continue")} phx-target={@myself}>
                Continue
              </.link>
            </Button.button>

            <div class="flex justify-center">
              <Button.button
                type="submit"
                size="xl"
                class="mt-2 w-min"
                phx-disable-with="Uploading..."
              >
                Upload
              </Button.button>
            </div>
          </.form>
        </Layout.col>
      </Layout.col>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    dbg(assigns)

    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:profile_photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "profile_image_file",
        max_file_size: 80_000_000,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "profile_photo")
        end
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Profile.change_user_picture(%Picture{}), as: :picture)
     end)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "value" => _value}, socket) do
    {:noreply, cancel_upload(socket, :profile_photo, ref)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("continue", _params, socket) do
    entries = socket.assigns.uploads.profile_photo.entries

    case Enum.count(entries) do
      0 ->
        {:noreply, socket}

      _ ->
        send(self(), {:success_upload, entries})
        {:noreply, socket}
    end
  end

  def handle_event("trigger", _unsigned_params, socket) do
    id = socket.assigns.current_user
    dbg(id)
    entries = socket.assigns.uploads.profile_photo.entries
    dbg(entries)

    consume_uploaded_entries(socket, :profile_photo, fn _meta, entry ->
      client_name = Map.get(entry, :client_name)
      filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)

      {:ok,
       %Picture{
         filename: filename,
         original_filename: client_name
       }}
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Good Work Dean")}
  end

  def handle_event("save", params, socket) do
    dbg(params)
    IO.puts("submit invoked")

    consume_uploaded_entries(socket, :profile_photo, fn _meta, entry ->
      client_name = Map.get(entry, :client_name)
      filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)

      {:ok,
       %Picture{
         filename: filename,
         original_filename: client_name
       }}
    end)

    # * consume_uploaded_entries ends here !! and at
    # * this point the picture has been uploaded to s3

    |> case do
      [] ->
        socket =
          socket
          |> assign(:photo_errors, %{filename: "is required"})

        {:noreply, socket}

      [%Picture{} = file] ->
        dbg(file)

        {:noreply, socket}
    end
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # defp assign_form(socket) do
  #   form =
  #     AshPhoenix.Form.for_create(Marketingbsm.Clockin.Checkin, :create,
  #       as: "checkin",
  #       actor: socket.assigns.current_user
  #     )

  #   assign(socket, form: to_form(form))
  # end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure "

  defp submit_form(socket, params, _file) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _checkin} ->
        socket =
          socket
          |> put_flash(:info, "Your Photo has Been received")
          |> push_patch(to: "/checkins")

        {:noreply,
         socket
         #  |> assign_form()
         |> assign(:uploaded_files, [])
         |> assign(:photo_errors, nil)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  attr :on_click, JS, required: true
  attr :drop_target_ref, :string, required: true
  attr :for, :string, required: true

  @doc """
  Renders a drop target to upload files
  """

  def droptarget(assigns) do
    ~H"""
    <div
      phx-click={@on_click}
      phx-drop-target={@drop_target_ref}
      for={@for}
      class="flex flex-col items-center max-w-2xl w-full py-8 px-6 mx-auto mt-2 text-center border-2 border-gray-300 border-dashed cursor-pointer dark:bg-gray-900 dark:border-gray-700 rounded-md"
    >
      <.icon name="hero-camera" class="w-8 h-8 mb-4 text-gray-500 dark:text-gray-400" />
      <Text.title>
        Take Your Photo
      </Text.title>
    </div>
    """
  end
end
