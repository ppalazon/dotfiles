function Inlines (inlines)
  local result = {}
  for i = 1, #inlines do
    local el = inlines[i]
    if el.t == "Str" then
      -- Match [[URL|Text]]
      local url, text = el.text:match("%[%[(https?://.-)|(.+)]]")
      if url and text then
        -- Convert to Pandoc link [Text](URL)
        table.insert(result, pandoc.Link(text, url))
      else
        table.insert(result, el)
      end
    else
      table.insert(result, el)
    end
  end
  return result
end
