function sin(x)
  return math.sin(x)
end

function cos(x)
  return math.cos(x)
end

function f1 (x)
  return 10000*math.exp(3*x)*math.sin(2*x)
end

function f2 (x)
  return 10000*math.exp(3*x)*math.sin(2*x)
end

function printFile(text,filename)
  if fileCount < 100 then
    local f = io.open(filename,"a")
    f:write("\n"..text)
    io.close(f)
    fileCount=fileCount+1
  end
end