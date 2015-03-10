local socket = require "socket"
local copev  = require "copas.ev"

local nb_threads    = 500
local nb_iterations = 500
local finished      = 0

local nb = 0
--local profiler = require "profiler"
--profiler:start "data.ou"
local start = socket.gettime ()

for i = 1, nb_threads do
  copev.addthread (function ()
    local skt = copev.wrap (socket.tcp ())
    skt:connect ("127.0.0.1", 8080)
    for j = 1, nb_iterations do
      skt:send "message\n"
      local answer = skt:receive "*l"
      assert (answer == "message")
      nb = nb + 1
    end
    finished = finished + 1
    if finished == nb_threads then
      assert (nb == nb_threads * nb_iterations)
      skt:send "stop\n"
      local average = math.floor (nb / (socket.gettime () - start))
      print ("# send/receive per second:", average)
--      profiler:stop ()
      os.exit (0)
    end
  end)
end

copev.loop ()