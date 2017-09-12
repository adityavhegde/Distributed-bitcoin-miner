defmodule Chain do
    def counter(parent) do
        numLeadingZeros = 7
        list = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n',
        'o','p','q','r','s','t','u','v','w','x','y','z','`','1','2','3',
        '4','5','6','7','8','9','0', '-', '=', '[', ']', '\\', ';', '\'',
        ',', '.', '/', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', 
        ')', '_', '+', '{', '}', '|', ':', '\"', '<', '>', '?']
        receive do
            {n, myPID} ->
                GenHash.perm_rep(list,[[]],n, numLeadingZeros-1)
                send parent, {:ok, myPID, n}
        end
    end
    
    def create_processes(n) do
        parent= self()
        Enum.each(1..n, fn(suffix_length)->
          worker = spawn(Chain, :counter, [parent])
          send worker, {suffix_length, worker}
        end)

        Enum.each(1..n, fn(_)->
          receive do
            {:ok, myPID, n} ->
              IO.puts "Checked completely for suffix of length #{n}"
              #IO.inspect myPID
          end
        end)
    end

    def run(n) do
        IO.puts inspect :timer.tc(Chain, :create_processes, [n])
        #Chain.create_processes(n)
    end
end

defmodule GenHash do
    #generate SHA-256 from string and convert to lowercase
    def stringToHash(string) do
        :crypto.hash(:sha256, string) |> Base.encode16 |> String.downcase
    end

    #generates permutations and checks for hash with leading zeroes
    def perm_rep(list1, list2, i, leadingZeros) do
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
                    hash |> String.slice(0..leadingZeros) == "0000000" ->
                    IO.puts [header, "    ", hash]
                    true ->
                        true
                end
                i != 1 ->
                    #recursively call the function with primary list and the concatenation of current x and y as inputs
                    perm_rep(list1,[[x|y]], i-1, leadingZeros)
            end
        end
    end
end

Chain.run(100)