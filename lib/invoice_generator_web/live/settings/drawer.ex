defmodule InvoiceGeneratorWeb.Settings.NavigationComponent do
  alias Tremorx.Components.Layout
  alias Tremorx.Components.Text
  alias Tremorx.Theme

  use InvoiceGeneratorWeb, :html
  use Phoenix.Component

  attr :user, :any, required: true
  attr :active_tab, :any, required: true

  def drawer(assigns) do
    ~H"""
    <div>
      <Layout.flex flex_direction="row">
        <.menu_item
          on_click={on_live_navigate(:report, ~p"/home")}
          active={@active_tab == "personal"}
          name="Personal"
        />

        <.menu_item
          on_click={on_live_navigate(:checkin, ~p"/home")}
          active={@active_tab == "password"}
          name="Password"
        />

        <.menu_item
          on_click={on_live_navigate(:template, ~p"/home")}
          active={@active_tab == "notifications"}
          name="Email notifications"
        />
      </Layout.flex>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :active, :boolean, default: false
  attr :on_click, JS, default: nil
  attr :class, :string, default: nil

  @doc """
  Renders a menu item button in the drawer
  """
  def menu_item(assigns) do
    ~H"""
    <button
      phx-click={if(is_nil(@on_click) == false, do: @on_click, else: nil)}
      class={
        Tails.classes([
          Theme.make_class_name("menu_button", "root"),
          Theme.get_spacing_style("two_xl", "padding_x"),
          Theme.get_spacing_style("lg", "padding_y"),
          "flex-shrink-0 inline-flex outline-none  rounded-tremor-default",
          if(@active,
            do: "bg-tremor-brand dark:bg-dark-tremor-brand hover:bg-tremor-brand-emphasis
            dark:hover:bg-dark-tremor-brand-emphasis text-tremor-brand-inverted
            dark:text-dark-tremor-brand-inverted font-semibold",
            else: "hover:bg-gray-100 text-tremor-content
          dark:text-dark-tremor-content hover:text-tremor-content-emphasis"
          ),
          if(is_nil(@class) == false, do: @class, else: nil)
        ])
      }
    >
      <Layout.flex>
        <Layout.flex
          class={
            Tails.classes([
              "space-x-4"
            ])
          }
          justify_content="start"
        >
          <Text.subtitle color="" class="">{@name}</Text.subtitle>
        </Layout.flex>
      </Layout.flex>
    </button>
    """
  end

  @doc false
  defp on_live_navigate(active_tab, href) do
    JS.push("on_live_navigate", value: %{active_tab: to_string(active_tab)})
    |> JS.patch(href)
  end
end
