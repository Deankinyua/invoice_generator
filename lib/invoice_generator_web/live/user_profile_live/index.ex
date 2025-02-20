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
  alias SimpleS3Upload

  alias InvoiceGenerator.Profile.Picture

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
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <fieldset>
            <.live_file_input type="file" upload={@uploads.photo} class="hidden pointer-events-none" />
          </fieldset>

          <.droptarget
            for={@uploads.photo.ref}
            on_click={JS.dispatch("click", to: "##{@uploads.photo.ref}", bubbles: false)}
            drop_target_ref={@uploads.photo.ref}
          />

          <%= for entry <- @uploads.photo.entries
                 do %>
            <article class="upload-entry">
              <figure>
                <.live_img_preview entry={entry} height="40" />
              </figure>

              <Layout.flex justify_content="start" align_items="center" class="space-x-4">
                <Layout.flex
                  justify_content="center"
                  class="w-16 h-16 bg-tremor-brand text-white rounded-md flex-shrink-0"
                >
                  <.icon name="hero-camera" class="h-6 w-6" />
                </Layout.flex>

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
                    >
                      Cancel
                    </Button.button>
                  </Layout.flex>

                  <Bar.progress_bar
                    :if={entry.progress > 0}
                    class="mt-3"
                    value={entry.progress}
                    show_animation={true}
                  />
                </Layout.flex>
              </Layout.flex>

              <%= for err <- upload_errors(@uploads.photo, entry) do %>
                <p class="alert alert-danger">{error_to_string(err)}</p>
              <% end %>
            </article>
          <% end %>

          <Button.button size="xl" type="submit" class="mb-10">
            Upload
          </Button.button>

          <Button.button phx-disable-with="Proceeding...">
            <.link phx-click={JS.push("continue")}>
              Continue
            </.link>
          </Button.button>
        </form>
      </div>

      <div class={unless @progress.name == "details", do: "hidden"}>
        <.live_component
          module={InvoiceGeneratorWeb.UserProfileLive.FormComponent}
          id="user_details"
          current_user={@current_user.id}
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
    socket =
      socket
      |> assign(form: to_form(Profile.change_user_picture(%Picture{}), as: :picture))
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "profile_image_file",
        max_file_size: 80_000_000,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "photo")
        end
      )

    first_step = Enum.at(@steps, 0)

    user_id = socket.assigns.current_user.id

    user_profile = %UserProfile{user_id: user_id}

    socket =
      socket
      |> assign(live_action: :new)
      |> assign(progress: first_step)
      |> assign(user_profile: user_profile)

    {:ok, socket}
  end

  # @impl true
  # def handle_info({:success_upload, entries}, socket) do
  #   second_step = Enum.at(@steps, 1)

  #   dbg(entries)

  #   IO.puts("video is in the process")

  #   {:noreply,
  #    socket
  #    |> assign(progress: second_step)}
  # end

  @impl true
  def handle_event("continue", _params, socket) do
    entries = socket.assigns.uploads.photo.entries

    case Enum.count(entries) do
      0 ->
        {:noreply, socket}

      _ ->
        second_step = Enum.at(@steps, 1)

        dbg(entries)

        {:noreply,
         socket
         |> assign(progress: second_step)}
    end
  end

  @impl true
  def handle_info({:valid_details, changeset}, socket) do
    {:noreply,
     socket
     |> assign(details: changeset)
     |> put_flash(:info, "Take the LiveView Pro Course its free :)")}
  end

  @impl true
  def handle_info(:back, socket) do
    dbg(socket.assigns)

    first_step = Enum.at(@steps, 0)

    IO.puts("going back")

    {:noreply,
     socket
     |> assign(progress: first_step)}
  end

  @impl true
  def handle_info(:save_invoked, socket) do
    IO.puts("save from details component received")

    consume_uploaded_entries(socket, :photo, fn _meta, entry ->
      client_name = Map.get(entry, :client_name)
      filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)

      picture_fields = %{filename: filename, original_filename: client_name}

      dbg(picture_fields)

      {:ok,
       %Picture{
         filename: filename,
         original_filename: client_name
       }}
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", params, socket) do
    dbg(socket.assigns.uploads)
    IO.puts("submit invoked")

    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn _meta, entry ->
        client_name = Map.get(entry, :client_name)
        filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)

        {:ok,
         %Picture{
           filename: filename,
           original_filename: client_name
         }}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}

    # * consume_uploaded_entries ends here !! and at
    # * this point the picture has been uploaded to s3

    # |> case do
    #   [] ->
    #     socket =
    #       socket
    #       |> assign(:photo_errors, %{filename: "is required"})

    #     {:noreply, socket}

    #   [%Picture{} = file] ->
    #     dbg(file)

    #     {:noreply, socket}
    # end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "value" => _value}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  def handle_params(unsigned_params, uri, socket) do
    dbg(unsigned_params)
    dbg(uri)
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

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:external_client_failure), do: "External client failure "
end
