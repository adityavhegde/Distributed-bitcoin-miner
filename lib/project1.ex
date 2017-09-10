defmodule GenHash do
  def stringToHash(string) do
    #generate SHA-256 from string and convert to lowercase
    :crypto.hash(:sha256, string) |> Base.encode16 |> String.downcase
  end
end

defmodule RC do
  def perm_rep(list), do: perm_rep(list, length(list))
  def perm_rep([], _), do: [[]]
  def perm_rep(_,  0), do: [[]]
  def perm_rep(list, i) do
    for x <- list, y <- perm_rep(list, i-1), do: [x|y]
  end
end
 
list = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
#list = ['a','b','c']
#Enum.each(3..3, fn n ->
#  IO.inspect RC.perm_rep(list,n)
#end)
Enum.each(1..26, fn n ->
  Enum.each(RC.perm_rep(list,n), fn header ->
      cond do
        Enum.join(["ahegde",header], "") |> GenHash.stringToHash |> String.slice(0..2) == "000" ->
          IO.puts Enum.join(["ahegde",header], "") |> GenHash.stringToHash
        true ->
          true#IO.puts 1#Enum.join(["ahegde",header], "") |> GenHash.stringToHash
      end
    end)
  end)