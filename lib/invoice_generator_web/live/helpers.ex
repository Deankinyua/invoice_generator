defmodule InvoiceGenerator.Helpers do
  alias InvoiceGenerator.Profile

  def get_profile_url(user_id) do
    case get_user(user_id) do
      nil ->
        ""

      user ->
        base_url = "http://127.0.0.1:9000/invoicegenerator/photo/"

        user_profile_picture_url = base_url <> user.picture.original_filename

        user_profile_picture_url
    end
  end

  defp get_user(user_id) do
    Profile.get_user_profile_by_user_id(user_id)
  end
end
