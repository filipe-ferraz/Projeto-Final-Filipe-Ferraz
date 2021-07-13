local printfile = {}

function printfile.printFile(text,filename)
  local f = io.open(filename,"a")
  f:write(text)
  io.close(f)
end

return printfile