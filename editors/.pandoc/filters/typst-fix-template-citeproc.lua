function Meta(meta)
  if meta.template then
    meta.template = pandoc.MetaString(
      pandoc.utils.stringify(meta.template)
    )
  end

  return meta
end