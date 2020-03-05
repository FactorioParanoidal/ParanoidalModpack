function string.starts(str, substr)
   return string.sub(str, 1, string.len(substr)) == substr
end