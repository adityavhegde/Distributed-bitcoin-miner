defmodule Chain do
    def counter(parent, numLeadingZeros) do
        list = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n',
        'o','p','q','r','s','t','u','v','w','x','y','z','`','1','2','3',
        '4','5','6','7','8','9','0']#, '-', '=', '[', ']', '\\', ';', '\'',
        #',', '.', '/', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', 
        #')', '_', '+', '{', '}', '|', ':', '\"', '<', '>', '?']
        receive do
            n ->
                GenHash.perm_rep(list,[[]],n, numLeadingZeros-1, parent)
                send parent, {:ok, :internal, n}
        end
    end

    # suffix length will be incremented as each receive executes
    # initial value of suffix length is set in the calling process
    def receiver(suffix_length, leadingZeros, nodes_list) do
        parent = self()
        interval = 4000

        receive do
            {:ok, :client, worker_name, n} ->
                worker = Node.spawn(worker_name, Chain, :counter, [self(), leadingZeros]) 
                send worker, suffix_length
                receiver(suffix_length + 1, leadingZeros, nodes_list)

            {:ok,:internal, n} ->
                IO.puts "done for suffix length #{n}"
                worker = spawn(Chain, :counter, [parent, leadingZeros])
                send worker, suffix_length
                receiver(suffix_length + 1, leadingZeros, nodes_list)

            #TODO: redundant code section
            {header, hashValue} -> 
                #IO.puts [header, "  ", hashValue]
                receiver(suffix_length, leadingZeros, nodes_list)
        after
            interval ->
                cond do
                    Enum.at(Node.list -- nodes_list, 0) == nil ->
                        receiver(suffix_length, leadingZeros, nodes_list)
                    true ->
                        worker = Node.spawn(Enum.at(Node.list -- nodes_list, 0), Chain, :counter, [self(), leadingZeros])
                        send worker, suffix_length
                        receiver(suffix_length + 1, leadingZeros, nodes_list ++ Enum.at(Node.list -- nodes_list, 0))
                end
                # discard below
                #Enum.each(Node.list -- nodes_list, fn(new_node_name) -> 
                    #TODO: spawn 8 processes here
                #    worker = Node.spawn(new_node_name, Chain, :counter, [self(), leadingZeros])
                 #   send worker, suffix_length
                #end)
                #temp = Node.list -- nodes_list
                #receiver(suffix_length + 1, leadingZeros, nodes_list ++ temp)
        end
    end

    def create_processes(leadingZeros, num_processes) do
        parent= self()
        Enum.each(1..num_processes, fn(suffix_length)->
          worker = spawn(Chain, :counter, [parent, leadingZeros])
          send worker, suffix_length
        end)

        Chain.receiver(num_processes, leadingZeros, [])
    end

end

defmodule GenHash do
    #generate SHA-256 from string and convert to lowercase
    def stringToHash(string) do
        :crypto.hash(:sha256, string) |> Base.encode16 |> String.downcase
    end

    #generates permutations and checks for hash with leading zeroes
    def perm_rep(list1, list2, i, leadingZeros, parent) do
        #comprehend through the two lists
        for x <- list1, y <- list2 do
            cond do
                #go till i and check only for that sized suffix
                i == 1 ->
                #concatenate prefix with generated permutation
                header = ["adityavhegde;"|[x|y]]
                hash = header |> stringToHash
                cond do
                    #output the string and its hash if found with required number of leading zeros
                    hash |> String.slice(0..leadingZeros) == String.duplicate("0", leadingZeros+1) ->
                    #IO.puts [header, "    ", hash]
                    send parent, {header, hash}
                    true ->
                        true
                end
                i != 1 ->
                    #recursively call the function with primary list and the concatenation of current x and y as inputs
                    perm_rep(list1,[[x|y]], i-1, leadingZeros, parent)
            end
        end
    end
end

defmodule Project1 do
  def main(args) do
    Node.start String.to_atom("aditya@192.168.0.12")
    Node.set_cookie :project1
    IO.inspect Node.self #, Node.get_cookie
    
    num_processes = 8
      args 
      |> parse_args 
      |> Enum.at(0) 
      |> Integer.parse(10) 
      |> elem(0) 
      |> Chain.create_processes(num_processes)
  end

  defp parse_args(args) do
    {_, word, _} = args 
    |> OptionParser.parse(strict: [limit: :integer])
    word
  end
end