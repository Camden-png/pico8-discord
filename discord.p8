pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
last = -1
steps = 0
timer = 0
global = nil
gems = false
coins1 = false
coins2 = false
player = {x = 16, y = 16}

function _init()
  cls()
  -- send 1 to python
		poke(0x4300, 1)
		serial(0x805, 0x4300, 1)
		-- reset memory
		poke(0x4300, 0)
		-- buffer
		flip()
end

-- send python strings with
-- $ as the null terminator
-- character by character
function output(string)
  string = string.."$"
  local length = #string
  for i = 1,length do
    local char = sub(string, i, i)
    local value = ord(char)
    poke(0x4316+i-1, value)
  end
  serial(0x805, 0x4316, length)
end

-- read strings from python
-- 16 bytes (characters) at
-- a time and set global to
-- the newest read string
function input()
  local string = ""
  local valid = true
		serial(0x804, 0x4300, 16)
		for i = 0,15 do
		  local value = peek(0x4300+i)
		  if value != 0 then
		    local char = chr(value)
		    string = string..char
		  else
		    if i == 0 then valid = false end
		    break
		  end
		end
		if valid then global = string end
end

function controls()
  if last == -1 then
    local x = player.x
    local y = player.y
    local b = global
    if (b == "l" or btn(0)) and x != 16 then
      last = 0
    elseif (b == "r" or btn(1)) and x != 104 then
      last = 1
    elseif (b == "u" or btn(2)) and y != 16 then
      last = 2
    elseif (b == "d" or btn(3)) and y != 104 then
      last = 3
    end
    global = nil
  end
  if last != -1 and time() - timer > 0.012 then
    if last == 0 then
      player.x -= 1
    elseif last == 1 then
      player.x += 1
    elseif last == 2 then
      player.y -= 1
    elseif last == 3 then
      player.y += 1
    end
    steps += 1
    timer = time()
    if steps == 8 then
      steps = 0
      last = -1
    end
  end
end

function _update60()
  controls()
  input()
  draw()
end

function merge(string)
  return string.." "..time()
end

function pickup(sprite, x, y, send, var)
  if var then return true end
  local bool = false
  if not var then
    if player.x == x and
    player.y == y then
      output(merge(send))
      bool = true
    end
    spr(sprite, x, y)
  end
  return bool
end

function draw()
  cls()
  rectfill(0, 0, 127, 127, 12)
  rectfill(16, 16, 111, 111, 6)
  rect(15, 15, 112, 112, 5)
  coins1 = pickup(1, 104, 016, "coins", coins1)
  coins2 = pickup(1, 016, 104, "coins", coins2)
  gems = pickup(2, 104, 104, "gems", gems)
  spr(0, player.x, player.y)
end
__gfx__
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbb3009999000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbb30979aa900171cc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3bb3b30999aa900111cc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbb309aaaa9001cccc1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3333b309aaaa90001cc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbb3009999000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
