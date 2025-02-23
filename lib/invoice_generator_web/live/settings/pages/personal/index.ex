defmodule InvoiceGeneratorWeb.SettingsLive.Index do
  use InvoiceGeneratorWeb, :live_view

  alias InvoiceGenerator.{Helpers}

  alias Ecto.Changeset
  alias InvoiceGenerator.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      {live_render(@socket, InvoiceGeneratorWeb.Header,
        session: %{
          "user" => "user?email=#{@current_user.email}"
        },
        id: "live_header",
        sticky: true
      )}

      {live_render(@socket, InvoiceGeneratorWeb.Settings.LiveDrawer,
        session: %{
          "active_tab" => "personal",
          "user" => "user?email=#{@current_user.email}"
        },
        id: "settings_live_drawer",
        sticky: true
      )}

      <div class="border border-blue-400 mx-4 py-20">
        <Layout.flex flex_direction="col">
          <Layout.flex flex_direction="row">
            <section class="h-36 w-36 rounded-full border-2 border-blue-400 overflow-hidden ">
              <img src={@profile_url} class="h-80 w-80 rounded-full object-cover object-center" />
            </section>

            <section class=" ">
              {@current_user.name} / Profile Information
            </section>
          </Layout.flex>
          <Layout.flex flex_direction="row">
            <section class="">
              <form id="upload-form" phx-submit="save" phx-change="validate">
                <Button.button size="xl" class="mb-10 bg-white hover:bg-white">
                  <fieldset>
                    <.live_file_input
                      type="file"
                      upload={@uploads.photo}
                      class="hidden pointer-events-none"
                    />
                  </fieldset>

                  <.droptarget
                    for={@uploads.photo.ref}
                    on_click={JS.dispatch("click", to: "##{@uploads.photo.ref}", bubbles: false)}
                    drop_target_ref={@uploads.photo.ref}
                  />
                </Button.button>

                <Button.button size="xl" class="mb-10">
                  <.link
                    phx-click={JS.push("delete", value: %{profile_url: @profile_url})}
                    data-confirm="Are you sure?"
                  >
                    Delete
                  </.link>
                </Button.button>
              </form>
            </section>
          </Layout.flex>
        </Layout.flex>

        <.live_component
          module={InvoiceGeneratorWeb.SettingsLive.PersonalDetails}
          id="settings_personal_address_details"
          current_user={@current_user}
        />

        <.live_component
          module={InvoiceGeneratorWeb.SettingsLive.BusinessDetails}
          id="settings_business_address_details"
          current_user={@current_user.id}
        />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(form: to_form(%{}, as: :picture))
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo,
        accept: ~w(.png .jpg .jpeg),
        max_entries: 1,
        id: "profile_image_file",
        max_file_size: 80_000_000,
        auto_upload: true,
        external: fn entry, socket ->
          SimpleS3Upload.presign_upload(entry, socket, "photo")
        end
      )

    user_id = socket.assigns.current_user.id

    profile_url = Helpers.get_profile_url(user_id)

    {:ok,
     socket
     |> assign(profile_url: profile_url)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    dbg(socket.assigns)
    entry = Enum.at(socket.assigns.uploads.photo.entries, 0)

    filename = Map.get(entry, :uuid) <> "." <> SimpleS3Upload.ext(entry)
    original_filename = entry.client_name
    details = %{filename: filename, original_filename: original_filename}

    send(self(), {:update_profile_picture, details})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:valid_personal_details, changeset}, socket) do
    dbg(changeset)
    # case submit_details(socket, changeset) do
    #   {:ok, _record} ->
    #     {:noreply,
    #      socket
    #      |> put_flash(:info, "User profile created successfully")
    #      |> redirect(to: ~p"/home")}

    #   {:error, _changeset} ->
    #     {:noreply,
    #      socket
    #      |> put_flash(:error, "You have already completed your profile!")
    #      |> redirect(to: ~p"/home")}
    # end
  end

  @impl true
  def handle_info(
        {:update_profile_picture, details},
        socket
      ) do
    user_id = socket.assigns.current_user.id

    user = Helpers.get_user(user_id)

    previous_picture = user.picture.original_filename

    delete_previous_profile_picture(previous_picture)

    changeset = Changeset.change(user, %{picture: details})
    Repo.update(changeset)

    {
      :noreply,
      socket
      |> redirect(to: "/personaldetails")
    }
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp delete_previous_profile_picture(file_name) do
    file_name = "photo/" <> file_name

    _result =
      ExAws.S3.delete_object("invoicegenerator", file_name)
      |> ExAws.request()
  end

  attr :on_click, JS, required: true
  attr :drop_target_ref, :string, required: true
  attr :for, :string, required: true

  @doc """
  Renders a drop target to upload files
  """

  def droptarget(assigns) do
    ~H"""
    <div phx-click={@on_click} phx-drop-target={@drop_target_ref} for={@for} class="bg-white">
      <Text.title>
        Upload a new photo
      </Text.title>
    </div>
    """
  end
end
