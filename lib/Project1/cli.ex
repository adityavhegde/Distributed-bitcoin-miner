defmodule Project1.CLI do
  def main(args) do
    {opts,_,_}= OptionParser.parse(args,switches: [file: :string],aliases: [f: :file])
    #IO.inspect opts
  end
end