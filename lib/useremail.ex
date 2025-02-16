defmodule InvoiceGenerator.UserEmail do
  # import Swoosh.Email

  use Phoenix.Swoosh,
    template_root: "lib/invoice_generator_web/templates/emails",
    template_path: "welcome"

  def welcome(user) do
    new()
    |> to(user.email)
    |> from("shattymtana@gmail.com")
    |> subject("Welcome to the Cookie Shop")
    |> render_body("welcome.html", %{name: user.name})
  end
end
