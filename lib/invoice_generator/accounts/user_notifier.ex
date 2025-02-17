defmodule InvoiceGenerator.Accounts.UserNotifier do
  import Swoosh.Email

  alias InvoiceGenerator.Mailer

  alias InvoiceGenerator.Accounts

  use Phoenix.Swoosh,
    template_root: "lib/invoice_generator_web/templates/emails",
    template_path: "welcome"

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, _body) do
    result = Accounts.get_user_by_email(recipient)

    email = result.email
    name = result.name

    dbg(recipient)
    dbg(name)
    dbg(email)

    email =
      new()
      |> to(recipient)
      |> from({"InvoiceGenerator", "shattymtana@gmail.com"})
      |> subject(subject)
      |> render_body("welcome.html", email: email, name: name)
      |> attachment(
        Swoosh.Attachment.new(
          Path.absname("priv/static/images/logo.png"),
          # content_type: "image/png",
          type: :inline
        )
      )

    # |> text_body(_body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
