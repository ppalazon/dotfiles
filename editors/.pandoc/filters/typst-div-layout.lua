function Div(div)

  local class = div.classes[1]

  if class ~= "pagewide"
     and class ~= "landscape"
     and class ~= "fullpage"
  then
    return nil
  end

  local body = pandoc.write(
    pandoc.Pandoc(div.content),
    "typst"
  )

  return pandoc.RawBlock(
    "typst",
    string.format(
      "#%s[\n%s\n]",
      class,
      body
    )
  )
end