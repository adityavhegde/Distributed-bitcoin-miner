defmodule Chain do
    def counter(parent) do
        numLeadingZeros = 2
        list = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n',
        'o','p','q','r','s','t','u','v','w','x','y','z','`','1','2','3',
        '4','5','6','7','8','9','0', '-', '=', '[', ']', '\\', ';', '\'',
        ',', '.', '/', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', 
        ')', '_', '+', '{', '}', '|', ':', '\"', '<', '>', '?']
        receive do
            n ->
                GenHash.perm_rep(list,[[]],n, numLeadingZeros-1, parent)
                send parent, {:ok, n}
        end
    end

    # suffix length will be incremented as each receive executes
    # initial value of suffix length is set in the calling process
    def receiver(suffix_length) do
        parent = self()
        receive do
            {:ok, n} ->
                worker = spawn(Chain, :counter, [parent])
                send worker, suffix_length + 1
                receiver(suffix_length + 1)

            {header, hashValue} -> 
                IO.puts [header, "  ", hashValue]
                receiver(suffix_length)

        end
    end
    
    def create_processes(n) do
        parent= self()

        Enum.each(1..n, fn(suffix_length)->
          worker = spawn(Chain, :counter, [parent])
          send worker, suffix_length
        end)

        Chain.receiver(n)
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
                    hash |> String.slice(0..leadingZeros) == "00" ->
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

Chain.run(6)