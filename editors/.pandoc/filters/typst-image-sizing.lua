function escape_typst_string(s)
  return s:gsub("\\", "\\\\"):gsub('"', '\\"')
end

function Image(img)
  local src = escape_typst_string(img.src)

  -- Convert alt text to plain text
  local alt = pandoc.utils.stringify(img.caption)

  -- Copy all attributes except width and height
  local attrs = {}
  for k, v in pairs(img.attributes) do
    if k ~= "width" and k ~= "height" then
      table.insert(
        attrs,
        string.format('%s: "%s"', k, escape_typst_string(v))
      )
    end
  end

  local attr_str = ""
  if #attrs > 0 then
    attr_str = ", " .. table.concat(attrs, ", ")
  end

  if alt ~= "" then
    attr_str = attr_str ..
      string.format(', alt: "%s"', escape_typst_string(alt))
  end

  return pandoc.RawInline(
    "typst",
    string.format(
      '#image("%s", width: 95%%, height: 33%%, fit: "contain"%s)',
      src,
      attr_str
    )
  )
end