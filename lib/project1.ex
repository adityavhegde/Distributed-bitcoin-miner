defmodule GenHash do
    #spawn initially N processes if this the server, each with a different suffix length
    def processesOnServer(leadingZeros, num_processes) do
        parent= self()
        Enum.each(1..num_processes, fn(suffix_length)->
          worker = Node.self() |> Node.spawn(GenHash, :workUnits, [parent, leadingZeros])
          send worker, suffix_length
        end)
        GenHash.receiver(num_processes+1, leadingZeros, [])
    end

    # suffix length will be incremented as each receive executes
    # initial value of suffix length is set in the calling process
    def receiver(suffix_length, leadingZeros, nodes_list) do
        parent = self()
        interval = 4000
        receive do
            #if received a message of a process having ended, spawn a 
            #new process on the corresponding node
            {:ok, worker_name, n} ->
                IO.puts "done for suffix length #{n}"
                worker = Node.spawn(worker_name, GenHash, :workUnits, [parent, leadingZeros]) 
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
                          worker = Node.list -- nodes_list 
                                    |> Enum.at(0) 
                                    |> Node.spawn(GenHash, :workUnits, [self(), leadingZeros])
                          send worker, suffix_length
                        end)
                        receiver(suffix_length + 16, leadingZeros, nodes_list ++ [Enum.at(Node.list -- nodes_list, 0)])
                end
        end
    end

    #the function called when a process is spawned
    def workUnits(parent, numLeadingZeros) do
        list = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
                "q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F",
                "G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V",
                "W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]
        receive do
            n ->
                Enum.each(1..100000000, fn(x) ->
                    GenHash.perm_rep(list, n, numLeadingZeros-1)
                end)
                send parent, {:ok, Node.self(), n}
        end
    end
    
    #called when suffix of given length is finally built. Combines it with 
    #given id, checks for hash, and prints if found with given no. of leading zeros
    def perm_rep(_, finalSuffix, 0, leadingZeros) do
        header = "adityavhegde;"<>finalSuffix
        hash = :crypto.hash(:sha256, header) |> Base.encode16 |> String.downcase
        cond do
            hash 
            |> String.slice(0..leadingZeros) == String.duplicate("0", leadingZeros+1) ->
                IO.puts [header, "    ", hash]
            true ->
                true
        end
    end
    #called recursively to build a suffix. Called first by perm_rep(list, length, leadingZeros, parent)
    def perm_rep(list, suffix, length, leadingZeros) do
        newSuffix = Enum.random(list)<>suffix
        GenHash.perm_rep(list, newSuffix, length-1, leadingZeros)
    end
    #First function to be called to start with a random character from the list. 
    #Then call perm_rep(list, suffix, length, leadingZeros, parent) to continue building suffix
    def perm_rep(list, length, leadingZeros) do
        suffix = Enum.random(list)
        GenHash.perm_rep(list, suffix, length-1, leadingZeros)
    end
end

defmodule Project1 do
  def main(args) do
  #get the ip of current node, and start it
    {:ok, list_ips} = :inet.getif()
    current_ip = list_ips 
                    |> Enum.at(0) 
                    |> elem(0) 
                    |> :inet_parse.ntoa 
                    |> IO.iodata_to_binary 
    nodeFullName = "mining@"<>current_ip
    Node.start String.to_atom(nodeFullName)
    Node.set_cookie :xyzzy
    IO.inspect {Node.self, Node.get_cookie}
    
    num_processes = 16
    cond do
      #check if ip is given, connect to the server
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
        #if number of leading zeros is given, start a server
        args 
        |> parse_args 
        |> Enum.at(0) 
        |> Integer.parse(10) 
        |> elem(0) 
        |> GenHash.processesOnServer(num_processes)
    end
  end

  #parsing the input argument
  defp parse_args(args) do
    {_, word, _} = args 
    |> OptionParser.parse(strict: [:integer])
    word
  end
end