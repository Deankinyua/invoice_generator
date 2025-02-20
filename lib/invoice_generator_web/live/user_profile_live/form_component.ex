defmodule InvoiceGeneratorWeb.UserProfileLive.FormComponent do
  use InvoiceGeneratorWeb, :live_component

  alias InvoiceGenerator.Profile

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="user_profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <Layout.col class="space-y-1.5">
          <Select.search_select
            id="country_id"
            name={@form[:country].name}
            placeholder="Choose Country"
            value={@form[:country].value}
            phx-update="ignore"
          >
            <:item :for={name <- @countries}>
              {name}
            </:item>
          </Select.search_select>
        </Layout.col>
        <Layout.col class="space-y-1.5">
          <.input field={@form[:city]} type="text" placeholder="City Name" />
        </Layout.col>
        <Layout.col class="space-y-1.5">
          <.input field={@form[:street]} type="text" placeholder="Street Address" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <.input field={@form[:postal_code]} type="text" placeholder="Postal Code" />
        </Layout.col>

        <Layout.col class="space-y-1.5">
          <.input field={@form[:phone]} type="text" placeholder="Phone Number" />
        </Layout.col>

        <:actions>
          <.button phx-disable-with="Saving..." class="hidden">Save User profile</.button>
        </:actions>

        <Button.button>
          <.link phx-click={JS.push("back")} phx-target={@myself}>
            Back
          </.link>
        </Button.button>

        <Button.button>
          <.link phx-click="trigger" phx-target="#user_picture">
            trigger
          </.link>
        </Button.button>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_profile: user_profile} = assigns, socket) do
    countries = countries()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:countries, countries)
     |> assign_new(:form, fn ->
       to_form(Profile.change_user_profile(user_profile))
     end)}
  end

  @impl true
  def handle_event("validate", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.user_profile, user_profile_params)

    case changeset.valid? do
      true ->
        send(self(), {:valid_details, changeset})

        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}

      false ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def handle_event("back", _params, socket) do
    send(self(), :back)
    {:noreply, socket}
  end

  def handle_event("save", %{"user_profile" => user_profile_params}, socket) do
    changeset = Profile.change_user_profile(socket.assigns.user_profile, user_profile_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}

    # save_user_profile(socket, socket.assigns.action, user_profile_params)
  end

  defp save_user_profile(socket, :edit, user_profile_params) do
    case Profile.update_user_profile(socket.assigns.user_profile, user_profile_params) do
      {:ok, user_profile} ->
        notify_parent({:saved, user_profile})

        {:noreply,
         socket
         |> put_flash(:info, "User profile updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user_profile(socket, :new, user_profile_params) do
    dbg(user_profile_params)
    user_profile_params = include_user_id(socket, user_profile_params)

    dbg(user_profile_params)

    case Profile.create_user_profile(user_profile_params) do
      {:ok, user_profile} ->
        dbg(user_profile)

        notify_parent({:saved, user_profile})

        {:noreply,
         socket
         |> put_flash(:info, "User profile created successfully")
         |> redirect(to: ~p"/welcome")}

      {:error, changeset} ->
        dbg(changeset)

        {:noreply,
         socket
         |> put_flash(:error, "User profile exists Already")
         |> redirect(to: ~p"/welcome")}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp include_user_id(socket, params) do
    id = socket.assigns.current_user

    map_with_id = %{"user_id" => id}

    params = Map.merge(params, map_with_id)

    params
  end

  defp countries do
    [
      "Afghanistan",
      "Albania",
      "Algeria",
      "Andorra",
      "Angola",
      "Antigua and Barbuda",
      "Argentina",
      "Armenia",
      "Australia",
      "Austria",
      "Azerbaijan",
      "Bahamas",
      "Bahrain",
      "Bangladesh",
      "Barbados",
      "Belarus",
      "Belgium",
      "Belize",
      "Benin",
      "Bhutan",
      "Bolivia",
      "Bosnia and Herzegovina",
      "Botswana",
      "Brazil",
      "Brunei",
      "Bulgaria",
      "Burkina Faso",
      "Burundi",
      "Cabo Verde",
      "Cambodia",
      "Cameroon",
      "Canada",
      "Central African Republic",
      "Chad",
      "Chile",
      "China",
      "Colombia",
      "Comoros",
      "Congo (Congo-Brazzaville)",
      "Costa Rica",
      "Croatia",
      "Cuba",
      "Cyprus",
      "Czechia",
      "Democratic Republic of the Congo",
      "Denmark",
      "Djibouti",
      "Dominica",
      "Dominican Republic",
      "Ecuador",
      "Egypt",
      "El Salvador",
      "Equatorial Guinea",
      "Eritrea",
      "Estonia",
      "Eswatini",
      "Ethiopia",
      "Fiji",
      "Finland",
      "France",
      "Gabon",
      "Gambia",
      "Georgia",
      "Germany",
      "Ghana",
      "Greece",
      "Grenada",
      "Guatemala",
      "Guinea",
      "Guinea-Bissau",
      "Guyana",
      "Haiti",
      "Honduras",
      "Hungary",
      "Iceland",
      "India",
      "Indonesia",
      "Iran",
      "Iraq",
      "Ireland",
      "Israel",
      "Italy",
      "Jamaica",
      "Japan",
      "Jordan",
      "Kazakhstan",
      "Kenya",
      "Kiribati",
      "Kuwait",
      "Kyrgyzstan",
      "Laos",
      "Latvia",
      "Lebanon",
      "Lesotho",
      "Liberia",
      "Libya",
      "Liechtenstein",
      "Lithuania",
      "Luxembourg",
      "Madagascar",
      "Malawi",
      "Malaysia",
      "Maldives",
      "Mali",
      "Malta",
      "Marshall Islands",
      "Mauritania",
      "Mauritius",
      "Mexico",
      "Micronesia",
      "Moldova",
      "Monaco",
      "Mongolia",
      "Montenegro",
      "Morocco",
      "Mozambique",
      "Myanmar (Burma)",
      "Namibia",
      "Nauru",
      "Nepal",
      "Netherlands",
      "New Zealand",
      "Nicaragua",
      "Niger",
      "Nigeria",
      "North Korea",
      "North Macedonia",
      "Norway",
      "Oman",
      "Pakistan",
      "Palau",
      "Palestine",
      "Panama",
      "Papua New Guinea",
      "Paraguay",
      "Peru",
      "Philippines",
      "Poland",
      "Portugal",
      "Qatar",
      "Romania",
      "Russia",
      "Rwanda",
      "Saint Kitts and Nevis",
      "Saint Lucia",
      "Saint Vincent and the Grenadines",
      "Samoa",
      "San Marino",
      "Sao Tome and Principe",
      "Saudi Arabia",
      "Senegal",
      "Serbia",
      "Seychelles",
      "Sierra Leone",
      "Singapore",
      "Slovakia",
      "Slovenia",
      "Solomon Islands",
      "Somalia",
      "South Africa",
      "South Korea",
      "South Sudan",
      "Spain",
      "Sri Lanka",
      "Sudan",
      "Suriname",
      "Sweden",
      "Switzerland",
      "Syria",
      "Tajikistan",
      "Tanzania",
      "Thailand",
      "Timor-Leste",
      "Togo",
      "Tonga",
      "Trinidad and Tobago",
      "Tunisia",
      "Turkey",
      "Turkmenistan",
      "Tuvalu",
      "Uganda",
      "Ukraine",
      "United Arab Emirates",
      "United Kingdom",
      "United States",
      "Uruguay",
      "Uzbekistan",
      "Vanuatu",
      "Vatican City",
      "Venezuela",
      "Vietnam",
      "Yemen",
      "Zambia",
      "Zimbabwe"
    ]
  end
end
