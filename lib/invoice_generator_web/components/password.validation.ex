defmodule InvoiceGeneratorWeb.Password.Validation.Component do
  use InvoiceGeneratorWeb, :live_component

  @impl true

  def render(assigns) do
    ~H"""
    <div>
      <Layout.flex
        flex_direction="col"
        align_items="start"
        class="gap-4 league-spartan-regular text-[#0C0E16]"
      >
        <p>
          Password must contain:
        </p>

        <Layout.flex flex_direction="col" align_items="start">
          <Layout.flex flex_direction="row" align_items="start">
            <Layout.flex
              flex_direction="row"
              align_items="center"
              justify_content="start"
              class="gap-1 flex-1"
            >
              <div>
                <img
                  src={~p"/images/circles/greencircle.svg"}
                  class={validation_feedback(:green, :length, @form_errors)}
                />

                <img
                  src={~p"/images/circles/graycircle.svg"}
                  class={validation_feedback(:gray, :length, @form_errors)}
                />
              </div>
              <p class="text-sm">8+ characters</p>
            </Layout.flex>
            <Layout.flex
              flex_direction="row"
              align_items="center"
              justify_content="start"
              class="gap-1 flex-1"
            >
              <div>
                <img
                  src={~p"/images/circles/greencircle.svg"}
                  class={validation_feedback(:green, :number, @form_errors)}
                />

                <img
                  src={~p"/images/circles/graycircle.svg"}
                  class={validation_feedback(:gray, :number, @form_errors)}
                />
              </div>
              <p class="text-sm">number</p>
            </Layout.flex>
            <Layout.flex
              flex_direction="row"
              align_items="center"
              justify_content="start"
              class="gap-1 flex-1"
            >
              <div>
                <img
                  src={~p"/images/circles/greencircle.svg"}
                  class={validation_feedback(:green, :uppercase, @form_errors)}
                />

                <img
                  src={~p"/images/circles/graycircle.svg"}
                  class={validation_feedback(:gray, :uppercase, @form_errors)}
                />
              </div>
              <p class="text-sm">upper-case</p>
            </Layout.flex>
          </Layout.flex>
        </Layout.flex>
        <Layout.flex
          flex_direction="row"
          align_items="center"
          justify_content="start"
          class="gap-1 flex-1"
        >
          <div>
            <img
              src={~p"/images/circles/greencircle.svg"}
              class={validation_feedback(:green, :special, @form_errors)}
            />

            <img
              src={~p"/images/circles/graycircle.svg"}
              class={validation_feedback(:gray, :special, @form_errors)}
            />
          </div>
          <p class="text-sm">special character (*#$%&!-@)</p>
        </Layout.flex>
      </Layout.flex>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  defp validation_feedback(circle_type, error_key, errors_map) do
    case Map.get(errors_map, error_key) do
      nil ->
        # means no errors exist

        if circle_type == :gray do
          "hidden"
        else
          "block"
        end

      _value ->
        # means errors exist

        if circle_type == :gray do
          "block"
        else
          "hidden"
        end
    end
  end
end
