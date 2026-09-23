-- Minimal JSON decoder (decode only). Conky's Lua has no JSON library and
-- shelling out to jq once per field every second is wasteful for a
-- ~15 KB document, so status.json is parsed in-process.
local M = {}

local function skip(s, i)
  return s:find("[^ \t\r\n]", i) or (#s + 1)
end

local decode_value

local function decode_string(s, i)
  local out, n = {}, 0
  i = i + 1
  while true do
    local j = s:find('["\\]', i)
    if not j then error("unterminated string") end
    n = n + 1
    out[n] = s:sub(i, j - 1)
    if s:sub(j, j) == '"' then
      return table.concat(out), j + 1
    end
    local esc = s:sub(j + 1, j + 1)
    if esc == "u" then
      local code = tonumber(s:sub(j + 2, j + 5), 16) or 63
      n = n + 1
      out[n] = utf8 and utf8.char(code) or "?"
      i = j + 6
    else
      local map = { b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }
      n = n + 1
      out[n] = map[esc] or esc
      i = j + 2
    end
  end
end

decode_value = function(s, i)
  i = skip(s, i)
  local c = s:sub(i, i)
  if c == "{" then
    local obj = {}
    i = skip(s, i + 1)
    if s:sub(i, i) == "}" then return obj, i + 1 end
    while true do
      i = skip(s, i)
      local key
      key, i = decode_string(s, i)
      i = skip(s, i)
      if s:sub(i, i) ~= ":" then error("expected ':'") end
      obj[key], i = decode_value(s, i + 1)
      i = skip(s, i)
      local d = s:sub(i, i)
      if d == "}" then return obj, i + 1 end
      if d ~= "," then error("expected ',' or '}'") end
      i = i + 1
    end
  elseif c == "[" then
    local arr, n = {}, 0
    i = skip(s, i + 1)
    if s:sub(i, i) == "]" then return arr, i + 1 end
    while true do
      n = n + 1
      arr[n], i = decode_value(s, i)
      i = skip(s, i)
      local d = s:sub(i, i)
      if d == "]" then return arr, i + 1 end
      if d ~= "," then error("expected ',' or ']'") end
      i = i + 1
    end
  elseif c == '"' then
    return decode_string(s, i)
  elseif s:sub(i, i + 3) == "true" then
    return true, i + 4
  elseif s:sub(i, i + 4) == "false" then
    return false, i + 5
  elseif s:sub(i, i + 3) == "null" then
    return nil, i + 4
  end
  local num = s:match("^-?%d+%.?%d*[eE]?[+-]?%d*", i)
  if not num or num == "" then error("unexpected character at " .. i) end
  return tonumber(num), i + #num
end

-- Returns the decoded value, or nil on any parse error.
function M.decode(s)
  if type(s) ~= "string" then return nil end
  local ok, value = pcall(function()
    local v = decode_value(s, 1)
    return v
  end)
  if ok then return value end
  return nil
end

return M
