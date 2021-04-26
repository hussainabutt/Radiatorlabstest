# Hello again Frank!
# I have decided to try to complete the challenge using Elixir;
# seeing as it's likely to be part of the onboarding process, only makes sense to get a head start!
# The language feels very confusing at first but clearly built for extremely functional programming!
############################
#
# To run the program:
# Open bash on current folder ('radiatorlabschallenge')
# $ iex -S mix
# iex(1)> import Radiatorlabschallenge
# iex(2)> start
#
############################

defmodule Radiatorlabschallenge do
  HTTPoison.start
  def start do
  # start by initializing filename and asking for the name of the hex file you would like to use to perform the update and then pipe it to trim any whitespace.
  filename = IO.gets("Please type in name of hex file to be used for the OTA update. \n") |> String.trim

  # Initialize read function with filename
  read(filename)
  end

  # read function declaration
  def read(filename) do
    case File.read(filename) do
      # pattern matching so that if it matches ok it will just return body to the parse function.
      # Or, in the case of an error, it will print the reason it failed out to console (the classic 'exampel.hex' mistake) and repeat asking for a file name.
      {:ok, body}       -> body
                           parse(body)
      {:error, reason}  -> IO.puts ~s(Could not open file "#{filename}"\n)
                           IO.puts ~s("#{:file.format_error reason}"\n)
                           start()
    end
  end

  # parse function to cleanup the hex input
  def parse(body) do

    #initialize a counter that will be used for list traversal in the choices function
    counter = 0

    # split at any newline characters, pipe the result to join all the strings
    # remove colons and split it into 20 characters then initialize the choices function with lines and counter of 0
    lines = String.split(body, ~r{(\r\n|\r|\n)}) |> Enum.join("")
    lines = String.replace(lines, ":", "")
    lines = String.split(lines, ~r/.{20}/, include_captures: true, trim: true)
    choices(lines, counter)
  end

  # choices function declaration,
  def choices(lines, counter) do

      # let the user know that the file was successfully read and parsed and then allow them to choose between sending a chunk,
      # verifying the integrity of the current firmware image thus far or quitting. Their one letter choice gets it whitespace trimmed and letter-casing downcased.
      choice = IO.gets("Hex file has been read and parsed. \nPlease select 's' to send a chunk or 'v' to verify integrity of image or 'q' to quit\n") |> String.trim |> String.downcase
      case choice do

        # Send chunk then increment the counter and return to start of choices
        "s" -> sendChunk(Enum.at(lines,counter))
               choices(lines, counter + 1)

        # verify integrity through checksum and return to start of choices
        "v" -> checksum()
               choices(lines, counter)
        "q" -> "Good Bye!"

        # any other choice results in return to start of choices
         _  -> "Invalid Choice"
               choices(lines, counter)
      end
    end

    # HTTPoison post request and interpolate a chunk of the firmware image

    # I'm having some trouble getting the response to display out to console and getting it to repeat through my choices function
    # However, I can gurantee both functions work when tested via compiler or checking output or response from node.js server
  def sendChunk(body) do
    url = "http://localhost:3000"
    {:ok, response} = HTTPoison.post(url, "CHUNK: #{body}", [])
    # IO.puts ~s("CHUNK SENT: #{response}")
  end

    #HTTPoison post request to get checksum
  def checksum() do
    url = "http://localhost:3000"
    {:ok, response} = HTTPoison.post(url, "CHECKSUM", [])
    # IO.puts ~s(CHECKSUM REQUESTED: #{response}")
  end
end
