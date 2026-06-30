local presets = {
  small = {
    width = "60%",
    height = "25%",
  },
  normal = {
    width = "95%",
    height = "33%",
  },
  wide = {
    width = "110%",
    height = "45%",
  },
  full = {
    width = "100%",
    height = "100%",
  },
}

local function escape_typst_string(s)
  return s:gsub("\\", "\\\\"):gsub('"', '\\"')
end

local function get_preset(img)
  local name = img.attributes["size"] or "normal"
  return presets[name] or presets.normal
end

function Image(img)
  local src = escape_typst_string(img.src)
  local alt = pandoc.utils.stringify(img.caption)

  local preset = get_preset(img)

  local attrs = {}

  for k, v in pairs(img.attributes) do
    if k ~= "width"
      and k ~= "height"
      and k ~= "size"
    then
      table.insert(
        attrs,
        string.format(
          '%s: "%s"',
          k,
          escape_typst_string(v)
        )
      )
    end
  end

  if alt ~= "" then
    table.insert(
      attrs,
      string.format(
        'alt: "%s"',
        escape_typst_string(alt)
      )
    )
  end

  local attr_str = ""
  if #attrs > 0 then
    attr_str = ", " .. table.concat(attrs, ", ")
  end

  return pandoc.RawInline(
    "typst",
    string.format(
      '#image("%s", width: %s, height: %s, fit: "contain"%s)',
      src,
      preset.width,
      preset.height,
      attr_str
    )
  )
end