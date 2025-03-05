import tokenizer


when isMainModule:
  let input = stdin.readAll()
  let tokens = tokenize(input)
  for token in tokens:
    echo token
