local mp = require("mp")

local colors_enabled = os.getenv("NO_COLOR") == nil and os.getenv("TERM") ~= "dumb"

local palette = {
  reset = "\27[0m",
  dim = "\27[2m",
  bold = "\27[1m",
  cyan = "\27[36m",
  green = "\27[32m",
  magenta = "\27[35m",
  yellow = "\27[33m",
}

local function style(name)
  if not colors_enabled then
    return ""
  end

  return palette[name] or ""
end

local function strip_ansi(text)
  return tostring(text or ""):gsub("\27%[[0-9;]*m", "")
end

local function next_utf8_char(text, index)
  local byte = text:byte(index)

  if not byte then
    return nil, index
  end

  local length = 1

  if byte >= 240 then
    length = 4
  elseif byte >= 224 then
    length = 3
  elseif byte >= 192 then
    length = 2
  end

  return text:sub(index, index + length - 1), index + length
end

local function codepoint(char)
  local b1, b2, b3, b4 = char:byte(1, 4)

  if not b1 then
    return 0
  end

  if b1 < 128 then
    return b1
  end

  if b1 < 224 and b2 then
    return (b1 - 192) * 64 + (b2 - 128)
  end

  if b1 < 240 and b2 and b3 then
    return (b1 - 224) * 4096 + (b2 - 128) * 64 + (b3 - 128)
  end

  if b2 and b3 and b4 then
    return (b1 - 240) * 262144 + (b2 - 128) * 4096 + (b3 - 128) * 64 + (b4 - 128)
  end

  return b1
end

local function in_range(value, ranges)
  for _, range in ipairs(ranges) do
    if value >= range[1] and value <= range[2] then
      return true
    end
  end

  return false
end

local combining_ranges = {
  { 0x0300, 0x036F },
  { 0x1AB0, 0x1AFF },
  { 0x1DC0, 0x1DFF },
  { 0x20D0, 0x20FF },
  { 0xFE20, 0xFE2F },
}

local wide_ranges = {
  { 0x1100, 0x115F },
  { 0x2329, 0x232A },
  { 0x2E80, 0xA4CF },
  { 0xAC00, 0xD7A3 },
  { 0xF900, 0xFAFF },
  { 0xFE10, 0xFE19 },
  { 0xFE30, 0xFE6F },
  { 0xFF00, 0xFF60 },
  { 0xFFE0, 0xFFE6 },
  { 0x1F300, 0x1FAFF },
  { 0x20000, 0x3FFFD },
}

local function char_width(char)
  local point = codepoint(char)

  if point == 0 or point < 32 or point == 127 or in_range(point, combining_ranges) then
    return 0
  end

  if in_range(point, wide_ranges) then
    return 2
  end

  return 1
end

local function text_width(text)
  local clean = strip_ansi(text)
  local width = 0
  local index = 1

  while index <= #clean do
    local char
    char, index = next_utf8_char(clean, index)

    if not char then
      break
    end

    width = width + char_width(char)
  end

  return width
end

local function terminal_content_width()
  local columns = tonumber(os.getenv("COLUMNS") or "")

  if columns and columns > 0 then
    return math.max(1, columns - 2)
  end

  return 78
end

local function terminal_rows()
  local rows = tonumber(os.getenv("LINES") or "")

  if rows and rows > 0 then
    return rows
  end

  return nil
end

local function clean_text(text)
  text = tostring(text or "")
  text = text:gsub("[%z\1-\31\127]", " ")
  text = text:gsub("…", "...")
  text = text:gsub("%s+", " ")
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  return text
end

local function truncate(text, max_width)
  text = clean_text(text)
  local ellipsis = "..."
  local ellipsis_width = text_width(ellipsis)

  if max_width <= ellipsis_width then
    return ellipsis
  end

  if text_width(text) <= max_width then
    return text
  end

  local result = ""
  local width = 0

  local index = 1

  while index <= #text do
    local char
    char, index = next_utf8_char(text, index)

    if not char then
      break
    end

    local next_width = char_width(char)

    if width + next_width > max_width - ellipsis_width then
      break
    end

    result = result .. char
    width = width + next_width
  end

  return result .. ellipsis
end

local function pad_right(text, target_width)
  local len = text_width(text)

  if len >= target_width then
    return text
  end

  return text .. string.rep(" ", target_width - len)
end

local function centered(text, target_width)
  local len = text_width(text)

  if len >= target_width then
    return text
  end

  local remaining = target_width - len
  local left = math.floor(remaining / 2)
  local right = remaining - left

  return string.rep(" ", left) .. text .. string.rep(" ", right)
end

local function format_time(seconds)
  if not seconds or seconds <= 0 then
    return "--:--"
  end

  seconds = math.floor(seconds)

  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60

  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, secs)
  end

  return string.format("%02d:%02d", minutes, secs)
end

local function progress_bar(position, duration, bar_width)
  local ratio = 0

  if duration and duration > 0 and position then
    ratio = math.max(0, math.min(1, position / duration))
  end

  local filled = math.floor(ratio * bar_width)

  if filled <= 0 then
    return style("magenta") .. "▸" .. style("dim") .. string.rep("─", bar_width - 1) .. style("reset")
  end

  if filled >= bar_width then
    return style("magenta") .. string.rep("━", bar_width - 1) .. "●" .. style("reset")
  end

  return style("magenta")
    .. string.rep("━", filled - 1)
    .. "●"
    .. style("dim")
    .. string.rep("─", bar_width - filled)
    .. style("reset")
end

local function property(name, fallback)
  local value = mp.get_property(name)

  if value == nil or value == "" then
    return fallback
  end

  return value
end

local function metadata(name)
  return property("metadata/by-key/" .. name, "")
end

local function render_screen()
  local width = terminal_content_width()
  local lines = {}

  local function push(text)
    lines[#lines + 1] = text
  end

  local function border(left, fill, right)
    push(style("dim") .. left .. string.rep(fill, width) .. right .. style("reset"))
  end

  local function empty_line()
    push(style("dim") .. "│" .. style("reset") .. string.rep(" ", width) .. style("dim") .. "│" .. style("reset"))
  end

  local function line(text)
    push(style("dim") .. "│" .. style("reset") .. pad_right(text, width) .. style("dim") .. "│" .. style("reset"))
  end

  local function centered_line(text)
    push(style("dim") .. "│" .. style("reset") .. centered(text, width) .. style("dim") .. "│" .. style("reset"))
  end

  local title = property("media-title", property("filename", "Unknown track"))
  local artist = metadata("Artist")
  local album = metadata("Album")
  local position = mp.get_property_number("time-pos", 0)
  local duration = mp.get_property_number("duration", 0)
  local volume = math.floor(mp.get_property_number("volume", 0))
  local paused = mp.get_property_bool("pause", false)
  local playlist_pos = mp.get_property_number("playlist-pos", 0) + 1
  local playlist_count = mp.get_property_number("playlist-count", 1)
  local state = paused and "PAUSED" or "PLAYING"
  local state_color = paused and "yellow" or "green"

  border("╭", "─", "╮")
  centered_line(style("cyan") .. style("bold") .. "▶  PLAYBACK" .. style("reset"))
  centered_line(style("dim") .. "mpv terminal control" .. style("reset"))
  empty_line()

  centered_line(style("bold") .. truncate(title, width - 8) .. style("reset"))

  if artist ~= "" then
    centered_line(style("cyan") .. truncate(artist, width - 8) .. style("reset"))
  else
    centered_line(style("dim") .. "unknown artist" .. style("reset"))
  end

  if album ~= "" then
    centered_line(style("dim") .. truncate(album, width - 8) .. style("reset"))
  else
    empty_line()
  end

  empty_line()

  local current_time = format_time(position)
  local total_time = format_time(duration)
  local content_width = width - 4
  local bar_width = math.max(1, content_width - text_width(current_time) - text_width(total_time) - 4)
  local bar = progress_bar(position, duration, bar_width)
  local progress = "  " .. current_time .. "  " .. bar .. "  " .. total_time

  line(progress)
  empty_line()

  local left_info = string.format("  %02d/%02d", playlist_pos, playlist_count)
  local badge = style(state_color) .. style("bold") .. state .. style("reset")
  local right_info = string.format("  Vol %d%%  ", volume)
  local spacing = width - text_width(left_info) - text_width(badge) - text_width(right_info)

  if spacing < 1 then
    spacing = 1
  end

  line(left_info .. string.rep(" ", spacing) .. badge .. right_info)
  empty_line()
  local controls = truncate("< previous    SPACE pause    > next    q quit", width)

  centered_line(style("dim") .. controls .. style("reset"))
  border("╰", "─", "╯")

  local rows = terminal_rows()
  local top_padding = 0

  if rows and rows > #lines then
    top_padding = math.floor((rows - #lines) / 2)
  end

  return string.rep("\n", top_padding) .. table.concat(lines, "\n") .. "\n"
end

local function render()
  local ok, screen = pcall(render_screen)

  if not ok then
    screen = "mpv terminal UI error: " .. tostring(screen) .. "\n"
  end

  io.stdout:write("\27[?25l\27[2J\27[H" .. screen)
  io.stdout:flush()
end

mp.add_periodic_timer(0.5, render)
mp.register_event("file-loaded", render)
mp.register_event("seek", render)
mp.observe_property("pause", "bool", render)
mp.observe_property("volume", "number", render)

mp.register_event("shutdown", function()
  io.stdout:write("\27[0m\27[?25h\n")
  io.stdout:flush()
end)

render()
