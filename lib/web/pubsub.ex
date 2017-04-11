defmodule Web.Pubsub do
  def subscribe(topic),
    do: :gproc.reg({:p, :l, topic |> String.to_char_list})

  def subscribers(topic),
    do: :gproc.lookup_pids({:p, :l, topic |> String.to_char_list})

  def publish(topic, message),
    do: :gproc.send({:p, :l, topic |> String.to_char_list}, message)
end
