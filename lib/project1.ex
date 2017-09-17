defmodule Chain do
    def counter(parent, numLeadingZeros) do
        list = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
                "q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F",
                "G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V",
                "W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]
        receive do
            n ->
                Enum.each(1..100000000, fn(x) ->
                    GenHash.perm_rep(list, n, numLeadingZeros-1, parent)
                end)
                send parent, {:ok, Node.self(), n}
        end
    end

    # suffix length will be incremented as each receive executes
    # initial value of suffix length is set in the calling process
    def receiver(suffix_length, leadingZeros, nodes_list) do
        parent = self()
        interval = 4000

        receive do
            {:ok, worker_name, n} ->
                IO.puts "done for suffix length #{n}"
                worker = Node.spawn(worker_name, Chain, :counter, [parent, leadingZeros]) 
                send worker, suffix_length
                receiver(suffix_length + 1, leadingZeros, nodes_list)
        after
            #check after an interval if a new client has connected
            interval ->
                cond do
                    Enum.at(Node.list -- nodes_list, 0) == nil ->
                        receiver(suffix_length, leadingZeros, nodes_list)
                    #if found a new client, spawn N initial processes on it
                    true ->
                        Enum.each(suffix_length..suffix_length+15, fn(suffix_length)->
                          worker = Node.list -- nodes_list |> Enum.at(0) |> Node.spawn(Chain, :counter, [self(), leadingZeros])
                          send worker, suffix_length
                        end)
                        receiver(suffix_length + 16, leadingZeros, nodes_list ++ [Enum.at(Node.list -- nodes_list, 0)])
                end
        end
    end

    #spawn initially N processes if this the server
    def create_processes(leadingZeros, num_processes) do
        parent= self()
        Enum.each(1..num_processes, fn(suffix_length)->
          worker = spawn(Chain, :counter, [parent, leadingZeros])
          send worker, suffix_length
        end)

        Chain.receiver(num_processes+1, leadingZeros, [])
    end

end

defmodule GenHash do
    #generate SHA-256 from string and convert to lowercase
    #def stringToHash(string) do
    #    :crypto.hash(:sha256, string) |> Base.encode16 |> String.downcase
    #end

    #generates permutations and checks for hash with leading zeroes
    def perm_rep(_, finalSuffix, 0, leadingZeros, parent) do
        header = "adityavhegde;"<>finalSuffix
        #header = finalSuffix
        hash = :crypto.hash(:sha256, header) |> Base.encode16 |> String.downcase
        cond do
            hash 
            |> String.slice(0..leadingZeros) == String.duplicate("0", leadingZeros+1) ->
                IO.puts [header, "    ", hash]
            true ->
                true
        end
    end
    def perm_rep(list, suffix, length, leadingZeros, parent) do
        newSuffix = Enum.random(list)<>suffix
        GenHash.perm_rep(list, newSuffix, length-1, leadingZeros, parent)
    end
    def perm_rep(list, length, leadingZeros, parent) do
        suffix = Enum.random(list)
        GenHash.perm_rep(list, suffix, length-1, leadingZeros, parent)
    end
end

defmodule Project1 do
  def main(args) do
  #get the ip of this node,  and start it
    #s = :inet_udp.open(0, []) |> elem(1)# |> IO.inspect
    #:prim_inet.ifget(s, "eth0", [addr])
    #IO.inspect :inet.getiflist()
    #IO.inspect :inet.getif()
    #node_ip = :inet.getif() |> elem(1) |> Enum.at(0) |> elem(0) |> Tuple.to_list |> Enum.join(".")
    #current_node = "mining@"<>node_ip
    #Node.start String.to_atom(current_node)
    Node.start String.to_atom("mining@10.228.7.92")
    Node.set_cookie :xyzzy
    IO.inspect {Node.self, Node.get_cookie}
    
    num_processes = 16
    cond do
      #check if ip is given
      args
      |> parse_args
      |> Enum.at(0) =~ "." ->
        server_ip = args |> Enum.at(0)
        server = "mining@"<>server_ip
        Node.connect String.to_atom(server)
        IO.inspect {"connected nodes", Node.list}
        receive do
          {:ok} ->
            true
        end
      true ->
        #if number of leading zeros is given
        args 
        |> parse_args 
        |> Enum.at(0) 
        |> Integer.parse(10) 
        |> elem(0) 
        |> Chain.create_processes(num_processes)
    end
  end

  defp parse_args(args) do
    {_, word, _} = args 
    |> OptionParser.parse(strict: [:integer])
    word
  end
end