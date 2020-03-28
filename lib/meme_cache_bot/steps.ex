defmodule MemeCacheBot.Steps do
  use GenServer

  # 1 hour
  @timeout 60 * 60 * 1000

  require Logger

  # Child specification
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_step(meme_info) do
    GenServer.call(__MODULE__, {:add_step, meme_info})
  end

  def get_step(uuid) do
    GenServer.call(__MODULE__, {:get_step, uuid})
  end

  # Server callbacks
  def init(:ok) do
    Process.send_after(self(), :timeout, @timeout)
    {:ok, %{first_gen: %{}, second_gen: %{}}}
  end

  def handle_info(:timeout, %{first_gen: first_gen}) do
    Logger.debug("Cleaning Steps genserver, next clean up in #{@timeout} ms")
    Process.send_after(self(), :timeout, @timeout)
    {:noreply, %{first_gen: %{}, second_gen: first_gen}}
  end

  def handle_call({:add_step, meme_info}, _from, %{
        first_gen: first_gen,
        second_gen: second_gen
      }) do
    uuid = UUID.uuid4()
    new_first_gen = Map.put(first_gen, uuid, meme_info)
    {:reply, {:ok, uuid}, %{first_gen: new_first_gen, second_gen: second_gen}}
  end

  def handle_call(
        {:get_step, uuid},
        _from,
        %{first_gen: first_gen, second_gen: second_gen} = state
      ) do
    case Map.get(first_gen, uuid, :no_meme_info) do
      :no_meme_info ->
        case Map.get(second_gen, uuid, :not_found) do
          :not_found ->
            {:reply, {:error, :not_found}, state}

          meme_info ->
            new_first_gen = Map.put(first_gen, uuid, meme_info)
            {:reply, {:ok, meme_info}, %{first_gen: new_first_gen, second_gen: second_gen}}
        end

      meme_info ->
        {:reply, {:ok, meme_info}, state}
    end
  end
end
