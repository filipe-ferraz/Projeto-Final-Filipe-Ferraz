
multi = 1

if multi == 0 then
  dofile("main_manual.lua")
elseif multi == 1 then
  dofile("main_single.lua")
elseif multi == 2 then
  dofile("main_multi.lua")
end