function Link(el)
  -- Convert [[Page|Title]] to [Title](Page.pdf)
  if el.target:match("%.md$") then
    el.target = el.target:gsub("%.md$", ".pdf")  -- Change links to .pdf
  end
  return el
end
