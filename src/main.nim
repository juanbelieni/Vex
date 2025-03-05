import tokenizer
import flag
import renderer

when isMainModule:
  let green = (r: 0'u8, g: 146'u8, b: 70'u8)
  let white = (r: 255'u8, g: 255'u8, b: 255'u8)
  let red = (r: 206'u8, g: 43'u8, b: 55'u8)

  var italyFlag = Flag(
    name: "Italy",
    proportions: (3, 2),
    elements: cast[seq[Element]](@[StripesElement(colors: @[green, white, red])]),
  )

  echo italyFlag.renderToSvg(600)

  # let input = stdin.readAll()
  # let tokens = tokenize(input)
  # for token in tokens:
  # echo token
