defmodule FluxonUIFirstWeb.PageController do
  use FluxonUIFirstWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
