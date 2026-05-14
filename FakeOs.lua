print("Loading Function")

local baseDir = "FakeOsDir"
os.execute("mkdir -p "..baseDir)

function centerText(text, width)
  if not width or width == ""then width = 40 or tonumber(os.getenv("COLUMNS")) end
  local pad = math.floor((width - #text) / 2)
  return string.rep(" ", pad) .. text
end

local function showUI()
  local list = {}

  for name, _ in pairs(commands) do
    table.insert(list, name)
  end

  table.sort(list)

  print(centerText("\n🖥️FAKEOS COMMAND CENTER"))
  print("------------------------")

  for _, name in ipairs(list) do
    print(" • " .. name)
  end

  print("------------------------\n")
end

function wait(sec)
  --[[local c = os.clock()
  while os.clock() - c < sec do end]]
  os.execute("sleep "..sec)
end

function progress(label, steps, r1, r2)
  io.write(label .. " ")
  local phr1 = 0
  local phr2 = 1
  if not r1 then r1 = phr1 end
  if not r2 then r2 = phr2 end
  for i = 1, steps do
    io.write("█")
    io.flush()
    os.execute("sleep "..math.random(r1, r2))
  end
  wait(0.1)
end

function contains(tbl, value)
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function normalize(value, min, max)
  return (value - min) / (max - min)
end

local function getAIApiKey()
  local f = io.open(baseDir.."/openRouterKey.key", "r")
  if f then
    local key = f:read("*l")
    f:close()
    return key
  end

  print("Enter your OpenRouter API key:")
  local key = io.read()

  local save = io.open(baseDir.."/openRouterKey.key", "w")
  save:write(key)
  save:close()

  return key
end



local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function base64_encode(data)
  return ((data:gsub('.', function(x)
    local r,bits='',x:byte()
    for i=8,1,-1 do
      r = r .. (bits%2^i - bits%2^(i-1) > 0 and '1' or '0')
    end
    return r
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do
      c = c + (x:sub(i,i)=='1' and 2^(6-i) or 0)
    end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

function base64_decode(data)
  data = data:gsub('[^'..b..'=]', '')
  return (data:gsub('.', function(x)
    if x == '=' then return '' end
    local r,f='',(b:find(x)-1)
    for i=6,1,-1 do
      r = r .. (f%2^i - f%2^(i-1) > 0 and '1' or '0')
    end
    return r
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if #x ~= 8 then return '' end
    local c = 0
    for i=1,8 do
      if x:sub(i,i) == '1' then
        c = c + 2^(8-i)
      end
    end
    return string.char(c)
  end))
end

wait(0.1)

print("Loading Data")

os.execute("mkdir -p LuaApps")

local serpKey = ""
do
  local f = io.open(baseDir.."/serp.key", "r")
  if f then
    serpKey = f:read("*l") or ""
    f:close()
  end
end

local version = "betaBuild 1.0"
print("Booting Up")
progress("            ", 10, 0, 1)
os.execute("clear")
print([[
██████ ▄▄▄  ▄▄ ▄▄ ▄▄▄▄▄ ▄████▄  ▄▄▄▄ 
██▄▄  ██▀██ ██▄█▀ ██▄▄  ██  ██ ███▄▄ 
██    ██▀██ ██ ██ ██▄▄▄ ▀████▀ ▄▄██▀ 
               by        ▗       
                  ▀▌▚▘▛▌▜▘▛▌▛▌▛▌
                  █▌▞▖▙▌▐▖▙▌▌▌▙▌
                                     ]])

wait(1)
os.execute("clear")

-- load session
local f = io.open(baseDir.."/session.txt", "r")
local currentUser = f and f:read("*a")
if f then f:close() end

-- load users
local users = {}
local f = io.open(baseDir.."/users.txt", "r")
if f then
  for line in f:lines() do
    local u, p = line:match("([^:]+):(.+)")
    if u and p then
      users[u] = p
    end
  end
  f:close()
end

-- if not logged in
if not currentUser or currentUser == "" then

  while true do
    print("\n1. Log in")
    print("2. Sign Up")
    io.write("> ")
    local choice = io.read()

    -- ================= LOGIN =================
    if choice == "1" then
      io.write("Username: ")
      local u = io.read()

      io.write("Password: ")
      local p = io.read()

      if users[u] and users[u] == p then
        currentUser = u

        local f = io.open(baseDir.."/session.txt", "w")
        f:write(u)
        f:close()

        print("Logged in as " .. u)
        print("Welcome, " .. u)
        break
      else
        print("Wrong username or password")
      end

    -- ================= SIGN UP =================
    elseif choice == "2" then
      io.write("New Username: ")
      local u = io.read()

      if users[u] then
        print("Username already exists")
      else
        io.write("New Password: ")
        local p = io.read()

        -- save user
        local f = io.open(baseDir.."/users.txt", "a")
        f:write(u .. ":" .. p .. "\n")
        f:close()

        print("Account created, please restart the OS")
        os.exit()
      end

    else
      print("Invalid option")
    end
  end

else
  print("Welcome back, "..currentUser..[[
  
  to get better visual,change font size to 16]])
end

commands ={}
aliases = {
  sd = "shutdown",
  calc = "calculator",
  enc = "encode",
  dec = "decode",
  cal = "calendar",
  clk = "clock",
  di = "deviceInfo",
  ip = "myIp",
  import = "install",
  open = "runApp",
  waf = "wordAveFind"
}

local lastArt = lastArt or ""
local filePath = baseDir.."/aliases.txt"

-- load aliases
local f = io.open(filePath, "r")
if f then
  for line in f:lines() do
    local a, c = line:match("^(.-)%s%|%s(.+)$")
    if a and c then
      aliases[a] = c
    end
  end
  f:close()
end

-- save function
local function saveAliases()
  local f = io.open(filePath, "w")
  for a, c in pairs(aliases) do
    f:write(a.." | "..c.."\n")
  end
  f:close()
end

-- alias command
commands["alias"] = function()
  io.write("Alias name: ")
  local name = io.read()

  io.write("Command: ")
  local cmd = io.read()

  aliases[name] = cmd
  saveAliases()

  print("Alias saved ✅")
end

-- hook into command runner (IMPORTANT)
local function resolve(input)
  if aliases[input] then
    return aliases[input]
  end
  return input
end


commands["net"] = function()
  print("Checking network...\n")
  
  local f = io.popen("ping -c 1 8.8.8.8 2>/dev/null")
  local res = f:read("*a")
  f:close()

  if res and res:find("1 received") then
    print("Internet: Connected")
  else
    print("Internet: Offline")
  end
end

commands["findExt"] = function()
  io.write("Extension: ")
  local ext = io.read()
  local path = "/storage/emulated/0"
  local num = 0

  if not ext then
    print("Please put the file extension")
    return
  end

  local p = io.popen('find "' .. path .. '" -name "*.' .. ext .. '" 2>/dev/null')

  local found = false

  for file in p:lines() do
    num = num + 1
    print(num..".", file)
    found = true
  end

  p:close()

  if not found then
    print("No files found")
  end
  return
end

commands["petal"] = function()
  local petals = math.random(5, 15)

  print("Petal game!")
  print("Petals:", petals, "\n")

  local state = true -- true = love me

  for i = 1, petals do
    if state then
      print(i..". Love me")
    else
      print(i..". Love me not")
    end

    state = not state
    io.read(1)
  end

  print("\nResult:")
  if not state then
    print("THEY LOVE YOU!")
  else
    print("THEY DON'T LOVE YOU...")
  end
end

commands["wordAveFind"] = function()
  local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 "

  io.write("Target word: ")
  local target = io.read()

  local function contains(t, v)
    for _, x in ipairs(t) do
      if x == v then
        return true
      end
    end
    return false
  end

  local function randomChar()
    local i = math.random(#chars)
    return chars:sub(i, i)
  end

  local function runOnce()
    local tries = 0
    local result = ""
    --local lastAttempt = {}

    for i = 1, #target do
      local correct = target:sub(i,i)
      local attempt = ""

      repeat
        attempt = randomChar()

        --[[if not contains(lastAttempt, attempt) then
          table.insert(lastAttempt, attempt)]]
          tries = tries + 1
        --end

      until attempt == correct

      result = result .. attempt
    end

    return tries
  end

  local total = 0
  local runs = 5

  for i = 1, runs do
    local t = runOnce()
    print("Run "..i.." tries:", t)
    total = total + t
  end

  print("\nAverage:", total / runs--[[, (normalize(total / runs, 0, total)*100).."%"]])
  
end

commands["changeUsername"] = function()
  while true do
    io.write("New username: ")
    local newU = io.read()
    print("y/n | use lowercase")
    local answer = io.read()
    if answer == "y" then
      f = io.open(baseDir.."/session.txt", "w")
      f:write(newU)
      print("Usernane changed to "..newU)
      f:close()
      print("Restart the OS please")
      os:exit()
      break
    elseif answer == "n" then
      break
    end
  end
end

commands["restart"] = function()

  print("Locating launcher...")

  local p = io.popen(
    'find . -type f -name "FakeLauncher.lua" 2>/dev/null'
  )

  local launcher = p:read("*l")

  p:close()

  if launcher then
    if package.config:sub(1,1) == "\\" then
      os.execute("cls")
    else
      os.execute("clear")
    end
    print("Restarting FakeOS...")
    dofile(launcher)
    error()
  else
    print("Launcher not found")
  end
end

commands["calculator"] = function()
  print("Type 'exit' to exit")
  while true do
    local input = io.read()
    if input == "exit" then break end
  
    input = input:gsub("sqrt", "math.sqrt")
    input = input:gsub("sin", "math.sin")
    input = input:gsub("cos", "math.cos")
    input = input:gsub("tan", "math.tan")
    input = input:gsub("log", "math.log")
    input = input:gsub("abs", "math.abs")
    input = input:gsub("pi", "math.pi")
    input = input:gsub("e", "math.exp(1)")
    input = input:gsub("floor", "math.floor")
  
    if not input:match("^[0-9%+%-%*/%%().%^a-z]+$") then
      print("Invalid Input!")
      return
    end
    
    local result = load("return " .. input)()
    if result then print(result) else print("nan") end
  end
end

commands["numberGuess"] = function()
  target = math.random(1,100)
  
  while true do
    print("Guess number (1-100):")
    guess = tonumber(io.read())

    if guess > target then
      print("Too high!")
    elseif guess < target then
      print("Too low!")
    else
      print("Correct!")
      break
    end
  end
end

commands["drawBin"] = function()
  os.execute("mkdir -p "..baseDir.."/Art")
  local info = ""
  
  if info == "" or not info then print("No info") else print("Info:", info) end

  while true do
    print("\n=== drawBin ===")
    print("1. Draw")
    print("2. View saved art")
    print("3. Delete art")
    print("4. Exit")
    io.write("# ")

    local choice = io.read()

    -- DRAW
    if choice == "1" then
      print("\nO = ⬛, I = ⬜")
      print("Type your drawing (END to finish)\n")

      local lines = {}

      while true do
        local input = io.read()
        if input == "END" then break end

        input = input:gsub("O", "⬛")
        input = input:gsub("I", "⬜")

        table.insert(lines, input)
      end

      lastArt = table.concat(lines, "\n")

      print("\nResult:\n")
      print(lastArt)

      -- AUTO SAVE
      local name = baseDir.."/"..os.date("%Y%m%d_%H%M%S")..".txt"
      local f = io.open(baseDir.."/Art/"..name, "w")
      f:write(lastArt)
      f:close()

      print("\nSaved!")

    -- VIEW SAVED
    elseif choice == "2" then
      local p = io.popen("ls "..FakeOsDir.."/Art 2>/dev/null")
      local files = {}

      for file in p:lines() do
        table.insert(files, file)
      end
      p:close()

      if #files == 0 then
        print("No saved art :(")
      else
        print("\nSaved Art:")
        for i, file in ipairs(files) do
          print(i..". "..file)
        end

        io.write("\nChoose number: ")
        local n = tonumber(io.read())

        if n and files[n] then
          local f = io.open(baseDir.."/Art/"..files[n], "r")
          local content = f:read("*a")
          f:close()

          print("\n"..content)
        else
          print("Invalid choice")
        end
      end
      
      -- DELETE ART
      elseif choice == "3" then
        local p = io.popen("ls "..FakeOsDir.."/Art 2>/dev/null")
        local files = {}
        
        for file in p:lines() do
          table.insert(files, file)
        end
        p:close()
        
        if #files == 0 then
          print("No art to delete")
        else
          print("\nSaved Art:")
          for i, file in ipairs(files) do
            print(i..". "..file)
          end
          
          io.write("\nDelete number: ")
          local n = tonumber(io.read())
          
          local filename = files[n]
          
          if filename then
            io.write("Are you sure? (y/n): ")
            if io.read() ~= "y" then
              os.remove(baseDir.."/Art/"..filename)
              print("Deleted!")
            else
              print("Canceled!")
            end
          else
            print("Invalid choice")
          end
        end

    -- EXIT
    elseif choice == "4" then
      break
    end
  end
end

commands["calendar"] = function() print(os.date("%A, %d %B %Y")) end

commands["clock"] = function() print(os.date("%X %Z")) end

commands["install"] = function()
  io.write("App URL(Raw code and lua only): ")
  local url = io.read()

  print("Downloading...")

  local f = io.popen('curl -s "'..url..'"')
  local code = f:read("*a")
  f:close()

  if not code or #code < 5 then
    print("Download failed")
    return
  end

  -- get name from raw github url
  local name = url:match("/([^/]+)%.lua$") or ("app_"..os.time())
  local path = baseDir.."/LuaApps/"..name..".lua"

  local file = io.open(path, "w")
  file:write(code)
  file:close()

  print("Installed: "..name.."")
end

commands["runApps"] = function(args)
  io.write("App name: ")
  local name = args or io.read()

  local path = baseDir.."/LuaApps/"..name..".lua"
  local f = io.open(path, "r")

  if not f then
    print("App not found")
    return
  end

  local code = f:read("*a")
  f:close()

  local ok, err = pcall(function()
    local app = load(code)
    if app then app() end
  end)

  if not ok then
    print("App crashed")
    print(err)
  end
end

commands["apps"] = function()
  local p = io.popen("ls "..FakeOsDir.."/LuaApps 2>/dev/null")

  if not p then
    print("No apps installed(Path not found)")
    return
  end

  print("Installed apps:")
  local empty = true

  for file in p:lines() do
    print("- "..file:gsub("%.lua$",""))
    empty = false
  end

  if empty then
    print("(none)")
  end

  p:close()
end

commands["serpAPI"] = function()
  io.write("Enter SerpAPI key: ")
  serpKey = io.read()

  local f = io.open(baseDir.."/serp.key", "w")
  f:write(serpKey)
  f:close()

  print("SerpAPI key saved ✅")
end

commands["search"] = function()
  -- load key
  if not serpKey or serpKey == "" then
    local f = io.open(baseDir.."/serp.key", "r")
    if f then
      serpKey = f:read("*l")
      f:close()
    end
  end

  if not serpKey or serpKey == "" then
    print("Run: serpAPI")
    return
  end

  io.write("Search: ")
  local q = io.read()

  -- fix spaces
  q = q:gsub(" ", "+")

  local url = "https://serpapi.com/search.json?q="..q.."&api_key="..serpKey

  local f = io.popen('curl -s "'..url..'"')
  local res = f:read("*a")
  f:close()

  -- debug (you can remove later)
  -- print(res)

  local i = 1

  -- better pattern (handles spacing)
  for title, link in res:gmatch('"title"%s*:%s*"(.-)".-"link"%s*:%s*"(.-)"') do
    print("["..i.."] "..title)
    print(link.."\n")
    i = i + 1
    if i > 5 then break end
  end

  if i == 1 then
    print("No results or API error ")
  end
end

commands["lua"] = function()
  print("Lua mode (type 'script.exit' to quit, use ; to seperate line)")
  print("Lua 5.4.8  Copyright (C) 1994-2025 Lua.org, PUC-Rio")

  while true do
    io.write("lua> ")
    local code = io.read()

    if code == "script.exit" then break end

    local f, err = load(code)
    if f then
      io.write("Output: ")
      f()
    else
      print("Error:", err)
    end
  end
end

commands["myIp"] = function()
  local f = io.popen("curl -s ipinfo.io")
  local data = f:read("*a")
  f:close()
  
  if data ~= "" then
    print(data)
  else
    print("Please turn on your Internet")
  end
end

commands["openRouterKey"] = function()
  print("Enter OpenRouter API key:")
  local key = io.read()

  local f = io.open(baseDir.."/openRouterKey.key", "w")
  f:write(key)
  f:close()

  print("API key saved.")
end

commands["ai"] = function()

  local API_KEY = getAIApiKey()
  local memory = {}
  local history = {}

  -- load memory
  local f = io.open(baseDir.."/aiMemory.txt", "r")
  if f then
    for line in f:lines() do
      local i, r = line:match("(.+)|(.+)")
      if i and r then
        memory[i] = r
      end
    end
    f:close()
  end

  print("AI ready (type 'exit' to quit)")

  while true do
    io.write("You: ")
    local input = io.read()
    
    local safe = input:gsub('"', '\\"')
    table.insert(history, '{\\"role\\":\\"user\\",\\"content\\":\\"'..safe..'\\"}')

    if not input then break end
    input = input:lower()

    if input == "exit" then
      print("AI: goodbye")
      break
    end

    -- memory check
    if memory[input] then
      print("AI:", memory[input])

    else
      print("AI: thinking...")

      -- escape quotes
      local safe = input:gsub('"', '\\"')
      
      local messages = table.concat(history, ",")

      -- FINAL WORKING CURL
      local cmd = 'curl -s https://openrouter.ai/api/v1/chat/completions '..'-H "Authorization: Bearer '..API_KEY..'" '..'-H "Content-Type: application/json" '..'-d "{'..'\\"model\\":\\"openrouter/free\\",'..'\\"messages\\":['..messages..']'..'}"'
      
      local p = io.popen(cmd)
      local res = p:read("*a")
      p:close()

      -- detect model
      local model = res:match('"model":"(.-)"')
      print("Current AI model:", model or "unknown")
      -- extract reply
      local reply = res:match('"content":"(.-)"')

      local p = io.popen(cmd)
      local res = p:read("*a")
      p:close()

      -- extract reply
      local reply = res:match('"content":"(.-)"')

      if reply then
        reply = reply:gsub('\\n', '\n')
        reply = reply:gsub('\\"', '"')

        print("AI:", reply)
        table.insert(history, '{\\"role\\":\\"assistant\\",\\"content\\":\\"'..reply:gsub('"','\\"')..'\\"}')
        if #history > 50 then
          table.remove(history, 2) -- keep system message
        end

        -- save to memory
        local file = io.open(baseDir.."/aiMemory.txt", "a")
        file:write(input .. "|" .. reply .. "\n")
        file:close()

        memory[input] = reply
      else
        print("AI: error or no response")
        -- print(res) -- uncomment if needed
      end
    end
  end
end

commands["aiMemClear"] = function()
  local f = io.open(baseDir.."/aiMemory.txt", "w")
  if f then
    f:write("")
    f:close()
  end
  print("AI memory cleared.")
end

commands["encode"] = function()
  print("Available mode: shift, reverse, hex, alpha, base64");print("")
  io.write("Mode: ")
  local mode = io.read()
  io.write("Text: ")
  local text = io.read()

  local result = ""

  if mode == "shift" then
    io.write("Key(Number only): ")
    local key = io.read()
    for i = 1, #text do
      result = result .. string.char(text:byte(i) + tonumber(key))
    end

  elseif mode == "reverse" then
    result = text:reverse()

  elseif mode == "hex" then
    for i = 1, #text do
      result = result .. string.format("%x ", text:byte(i))
    end
  elseif mode == "base64" then
    result = base64_encode(text)
  elseif mode == "alpha" then
    for c in text:lower():gmatch(".") do
      if c:match("%a") then
        result = result .. (c:byte() - 96) .. " "
      else
        result = result .. c .. " "
      end
    end
  else
    print("Unknown mode")
    return
  end
  
  local ok, err = pcall(function()
    print(result)
  end)
  
 if not ok then
    print("Something wrong")
    print(err)
  end
end

commands["decode"] = function()
    print("Available mode: shift, reverse, hex, alpha, base64");print("")
  io.write("Mode: ")
  local mode = io.read()
  io.write("Text: ")
  local text = io.read()

  local result = ""

  if mode == "shift" then
    io.write("Key(Number only): ")
    local key = io.read()
    for i = 1, #text do
      result = result .. string.char(text:byte(i) - key)
    end

  elseif mode == "reverse" then
    result = text:reverse()

  elseif mode == "hex" then
    for hex in text:gmatch("%S+") do
      result = result .. string.char(tonumber(hex, 16))
    end
  elseif mode == "base64" then
    result = base64_decode(text)
  elseif mode == "alpha" then
    for num in text:gmatch("%S+") do
      local n = tonumber(num)
      if n and n >= 1 and n <= 26 then
        result = result .. string.char(n + 96)
      else
        result = result .. "?"
      end
    end
  else
    print("Unknown mode")
    return
  end
  
  local ok, err = pcall(function()
    print(result)
  end)
  
  if not ok then
    print("Something wrong")
    print(err)
  end
end

commands["minesweeper"] = function()
  local width = 10
  local height = 10
  local mineCount = 10

  local grid = {}
  local revealed = {}
  
  local title = "Minesweeper"
  if math.random(1, 2000) == 1 then
    title = "Minecreeper"
  end

  print(title)
  print("Commands: r x y (reveal), f x y (flag)\n")
  os.execute("sleep 1")

  -- init grid
  for y = 1, height do
    grid[y] = {}
    revealed[y] = {}
    for x = 1, width do
      grid[y][x] = 0
      revealed[y][x] = false
    end
  end

  -- place mines
  local placed = 0
  while placed < mineCount do
    local x = math.random(1, width)
    local y = math.random(1, height)

    if grid[y][x] ~= "M" then
      grid[y][x] = "M"
      placed = placed + 1
    end
  end

  -- count mines
  local function countMines(x, y)
    local count = 0

    for dy = -1, 1 do
      for dx = -1, 1 do
        local nx, ny = x + dx, y + dy

        if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
          if grid[ny][nx] == "M" then
            count = count + 1
          end
        end
      end
    end

    return count
  end

  -- render
  local function draw()
    os.execute("clear")

    print(title)

    for y = 1, height do
      local line = ""
      for x = 1, width do

        if not revealed[y][x] then
          line = line .. "■"
        else
          if grid[y][x] == "M" then
            line = line .. "*"
          else
            line = line .. tostring(countMines(x, y))
          end
        end

      end
      print(line)
    end
  end

  -- game loop
  while true do
    draw()

    io.write("> ")
    local input = io.read()

    local cmd, x, y = input:match("(%a)%s+(%d+)%s+(%d+)")
    x = tonumber(x)
    y = tonumber(y)

    if cmd == "r" then
      if grid[y][x] == "M" then
        print("BOOM!")
        break
      end
      revealed[y][x] = true

    elseif cmd == "f" then
      print("flag placed (fake system)")
    end
  end
end

commands["clear"] = function() os.execute("clear") end

commands["wordle"] = function()

  local listOfWord = {"water","green","birch","guest","class","unite","plane","spell","state","glass","fight","hello","sigma","glory","ghost","faith","drain","brain","bloom","legal","wheat","combo","short","plead","shell","limbo","block","broom","gloom","bloom","clean","plain","plant","human","furry","color","oiled","pussy","nigga","dough","tough","negro","fried","cried","inbox","dowel","kefir","knell","loris","gizmo"}

  -- today (simple format)
  local today = os.date("%Y-%m-%d")

  -- check last play
  local lastPlayed = ""
  local f = io.open(baseDir.."/wordle.date", "r")
  if f then
    lastPlayed = f:read("*l") or ""
    f:close()
  end

  if lastPlayed == today then
    print("You already played today ")
    return
  end

  -- DAILY WORD SYSTEM
  local start = os.time{year=2021, month=6, day=19}
  local now = os.time()
  local days = math.floor((now - start) / 86400)
  local index = (days % #listOfWord) + 1
  local selectedWord = listOfWord[index]

  print("Wordle (Daily)")

  local chance = 6
  local chanceNum = 1

  while true do
    io.write(chanceNum.." ")
    local guess = io.read()

    if #guess ~= #selectedWord then
      print("Please put "..#selectedWord.." characters")
      goto continue
    end

    local result = {}
    local used = {}

    -- Green
    for i = 1, #selectedWord do
      if guess:sub(i,i) == selectedWord:sub(i,i) then
        result[i] = "🟩"
        used[i] = true
      end
    end

    -- Yellow / Red
    for i = 1, #selectedWord do
      if not result[i] then
        local g = guess:sub(i,i)
        local found = false

        for j = 1, #selectedWord do
          if not used[j] and g == selectedWord:sub(j,j) then
            found = true
            used[j] = true
            break
          end
        end

        result[i] = found and "🟨" or "🟥"
      end
    end

    print(table.concat(result))

    if guess == selectedWord then
      print("Wordle Complete!")

      -- save today as played
      local f = io.open(baseDir.."/wordle.date", "w")
      f:write(today)
      f:close()

      break
    else
      chanceNum = chanceNum + 1
      if chanceNum > chance then
        print("Game Over, The answer is "..selectedWord)

        -- still count as played
        local f = io.open(baseDir.."/wordle.date", "w")
        f:write(today)
        f:close()

        break
      end
    end

    print("")
    ::continue::
  end
end

commands["logout"] = function()
  local f = io.open(baseDir.."/session.txt", "w")
  f:write("")
  f:close()
  
  currentUser = nil
  print("Logged Out")
  os.exit()
end

commands["shutdown"] = function()
  os.execute("clear")
  print("             Shutting Down")
  wait(1)
  os.execute("clear")
  os.exit()
end

commands["note"] = function()
  local readOnly = false
  local note = io.open(baseDir.."/note.txt", "r")
  local content = note and note:read("*a")
  if content == nil then content = "" end
  if note then note:close() end
  print("clear(c), read(r), or edit(e)")
  while true do
    local answer = io.read()
    if answer == "c" then
      readOnly = true
      local note = io.open(baseDir.."/note.txt", "w")
      note:write("")
      content = ""
      note:close()
      print("Note Cleared")
      break
    elseif answer == "r" then
      readOnly = true
      break
    else
      readOnly = false
      break
    end
  end
  if content and readOnly == true then print("Note: ");print(content) end
  while true do
    if readOnly == false then
      io.write(content)
      local addition = io.read()
      local note = io.open(baseDir.."/note.txt", "w")
      note:write(content..addition)
      note:close()
      print("Saved")
    end
    break
  end
end

commands["shutdown"] = function() progress("Shutting Down ", 10);os.execute("clear");os.exit()
end

commands["deviceInfo"] = function()
  local function get(cmd)
  local f = io.popen(cmd .. " 2>/dev/null")
  local r = f and f:read("*l") or "unknown"
  if f then f:close() end
    return r
  end
  
  local mem = collectgarbage("count")
  local kb = tonumber(get("grep MemAvailable /proc/meminfo | awk '{print $2}'")) or 0
  
  local file = io.open(baseDir.."/fakeOs.lua", "r")

  local lineCount = 0
  local charCount = 0

  for line in file:lines() do
    lineCount = lineCount + 1
    charCount = charCount + #line + 1 -- +1 for newline
  end

  file:close()

  print("Total lines:", lineCount)
  print("Total characters:", charCount)
  
  print("Brand:", get("getprop ro.product.brand"))
  print("Device:", get("getprop ro.product.device"))
  print("Model:", get("getprop ro.product.model"))
  print("SDK:", get("getprop ro.build.version.sdk"))
  
  print(string.format(
  "Free Memory: %.2f MB (%.2f GB)",
  kb/1000, kb/1000000
  ))
  
  print(string.format(
  "Memory: %.2f MB (%.4f GB)",
  mem/1000, mem/1000000
  ))
  
  print("fakeOs Version: "..version)
end

--[[commands["LoC"] = function()
  print("List of Commands: ")
  local keys = {}

  for k, _ in pairs(commands) do
    table.insert(keys, k)
  end

  table.sort(keys)
  
  for _, k in ipairs(keys) do
    print(k)
  end
end]]

commands["aliases"] = function()
  print("List of Aliases")
  local keys = {}

  for k, _ in pairs(aliases) do
    table.insert(keys, k)
  end

  table.sort(keys)
  
  for _, k in ipairs(keys) do
    print(k)
  end
end

showUI()
while true do
  io.write("> ")
  cmd = io.read()
  
  if aliases and aliases[cmd] then
    cmd = aliases[cmd]
  end
  
  if commands[cmd] --[[or commands[cmd](args)]] then
    commands[cmd](args)
  else
    print("Unknown command")
  end
end
