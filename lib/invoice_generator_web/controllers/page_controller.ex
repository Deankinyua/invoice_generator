defmodule InvoiceGeneratorWeb.PageController do
  use InvoiceGeneratorWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/welcome")
    # render(conn, :home, layout: false)
  end
end
