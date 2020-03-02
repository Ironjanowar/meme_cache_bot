defmodule MemeCacheBot.Steps do
  use GenServer

  # Child specification
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  # Client API
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_step(user_id, step) do
    GenServer.cast(__MODULE__, {:add_step, user_id, step})
  end

  def get_step(user_id) do
    GenServer.call(__MODULE__, {:get_step, user_id})
  end

  def extract_step(user_id) do
    GenServer.call(__MODULE__, {:extract_step, user_id})
  end

  # Server callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:add_step, user_id, step}, state) do
    {:noreply, Map.put(state, user_id, step)}
  end

  def handle_call({:get_step, user_id}, _from, state) do
    case Map.get(state, user_id, :no_step) do
      :no_step -> {:reply, {:error, :no_step}, state}
      step -> {:reply, {:ok, step}, state}
    end
  end

  def handle_call({:extract_step, user_id}, _from, state) do
    case Map.pop(state, user_id, :no_step) do
      {:no_step, _} -> {:reply, {:error, :no_step}, state}
      {reply, new_state} -> {:reply, {:ok, reply}, new_state}
    end
  end
end
