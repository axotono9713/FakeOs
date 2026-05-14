-- =========================
-- COFIG
-- =========================
local p = io.popen("ps")
local package = p:read("*a")
p:close()

if not package:find("com.alif.ide.lua", 1, true) then
  print("Please use luadroid")
  os.exit()
end

local ctnt = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2F4b3Rvbm85NzEzL0Zha2VPcy9yZWZzL2hlYWRzL21haW4vRmFrZU9z"

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function f1(data)
  data = string.gsub(data, '[^'..b..'=]', '')
  return (data:gsub('.', function(x)
    if (x == '=') then return '' end
    local r, f = '', (b:find(x) - 1)
    for i = 6, 1, -1 do 
      r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') 
    end
    return r;
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if (#x ~= 8) then return '' end
    local c = 0
    for i = 1, 8 do 
      c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) 
    end
    return string.char(c)
  end))
end

URL = f1(ctnt)

local LOCAL_FILE = "FakeOsDir/fakeOs.lua"

-- =========================
-- FETCH FROM WEB
-- =========================
local function fetch()
  local f = io.popen('curl -s "' .. URL .. '"')
  if not f then return nil end

  local code = f:read("*a")
  f:close()

  if code and #code > 50 then -- basic sanity check
    return code
  end
end
os.execute("sleep 0.1")
-- =========================
-- SAVE LOCAL COPY
-- =========================
local function save(code)
  local f = io.open(LOCAL_FILE, "w")
  if f then
    f:write(code)
    f:close()
  end
end

-- =========================
-- LOAD LOCAL COPY
-- =========================
local function loadLocal()
  local f = io.open(LOCAL_FILE, "r")
  if not f then return nil end

  local code = f:read("*a")
  f:close()
  return code
end

-- =========================
-- MAIN LOADER
-- =========================
print("Checking internet...")

local code = fetch()

if code then
  print("Online mode (latest version)")
  print("Saving latest version...")
  save(code)
  print("Done!")
else
  print("Offline mode (cached/saved version)")
  code = loadLocal()
end

if not code then
  print("No system found")
  return
end

-- =========================
-- CHECK AND INSTALL PRE-INSTALLED APP
-- =========================

local preinstalled = {
  "snake"
}

print("Checking cherry")
local baseURL = "https://raw.githubusercontent.com/yourname/fakeos/main/apps/"

for _, app in ipairs(preinstalled) do
  local path = "FakeOsDir/LuaApps/"..app..".lua"

  local f = io.open(path, "r")
  if f then
    f:close()
    print("Os has the cherry")
  else
    print("Installing cherry...")

    local url = baseURL..app..".lua"
    local cmd = ''
    if url then cmd = 'curl -s "'..url..'" -o "'..path..'"' else print("A cherry not installed") end
    os.execute("mkdir -p FakeOsDir/LuaApps")
    os.execute(cmd)

    print("A cherry installed")
  end
end

-- =========================
-- RUN SYSTEM
-- =========================
local ok, err = pcall(function()
  load(code)() 
end)

if not ok then
  print("Crash detected:")
  print(err)
end
