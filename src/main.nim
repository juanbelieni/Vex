import tokenizer
# import flag
import renderer
import parser

when isMainModule:
  let input = stdin.readAll()
  let tokens = tokenize(input)
  let flag = parse(tokens)
  let svg = renderToSvg(flag, 3600)
  echo svg
