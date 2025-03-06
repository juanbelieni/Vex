import tokenizer
import flag
import std/strutils
import std/strformat

proc error(message: string, token: Token) =
  echo fmt"Error: {message} at line {token.line}, column {token.column}, token: {token.value} of kind {token.kind}"
  quit(1)

proc peek(tokens: seq[Token], i: int): Token =
  if i >= tokens.len:
    return Token(kind: tkEOF, value: "", line: 0, column: 0)
  else:
    return tokens[i]

proc expect(tokens: seq[Token], i: var int, kind: TokenKind, message: string): Token =
  let token = peek(tokens, i)
  if token.kind == kind:
    inc(i)
    return token
  else:
    error(message, token)

proc parseFloat(token: Token): float =
  try:
    return token.value.parseFloat()
  except ValueError:
    error("Expected floating point number", token)

proc parseUInt(token: Token): uint =
  try:
    return token.value.parseUInt()
  except ValueError:
    error("Expected unsigned integer", token)

proc parseBool(token: Token): bool =
  if token.value == "true":
    return true
  elif token.value == "false":
    return false
  else:
    error("Expected boolean value ('true' or 'false')", token)

proc parseX[T: Element](tokens: seq[Token], i: var int, element: var T) =
  let valueToken = expect(tokens, i, tkNumber, "Expected number")
  element.x = parseFloat(valueToken)

proc parseY[T: Element](tokens: seq[Token], i: var int, element: var T) =
  let valueToken = expect(tokens, i, tkNumber, "Expected number")
  element.y = parseFloat(valueToken)

proc parseWidth[T: Element](tokens: seq[Token], i: var int, element: var T) =
  let valueToken = expect(tokens, i, tkNumber, "Expected number")
  element.width = parseFloat(valueToken)

proc parseHeight[T: Element](tokens: seq[Token], i: var int, element: var T) =
  let valueToken = expect(tokens, i, tkNumber, "Expected number")
  element.height = parseFloat(valueToken)

proc parseRotation[T: Element](tokens: seq[Token], i: var int, element: var T) =
  let valueToken = expect(tokens, i, tkNumber, "Expected number")
  element.rotation = parseFloat(valueToken)

proc parseCentered[T: Element](tokens: seq[Token], i: var int, element: var T) =
  let valueToken = expect(tokens, i, tkIdentifier, "Expected 'true' or 'false'")
  element.centered = parseBool(valueToken)

proc parseColor[T: ColoredElement](tokens: seq[Token], i: var int, element: var T) =
  let colorToken = expect(tokens, i, tkColor, "Expected color")
  element.color = colorFromHex(colorToken.value)

proc parseRadius[T: CircleElement](tokens: seq[Token], i: var int, element: var T) =
    let valueToken = expect(tokens, i, tkNumber, "Expected number")
    element.radius = parseFloat(valueToken)

proc parseCircle(tokens: seq[Token], i: var int): CircleElement =
  var circle = CircleElement()

  discard expect(tokens, i, tkLBrace, "Expected '{'")

  while true:
    let nextToken = peek(tokens, i)
    if nextToken.kind == tkRBrace:
      break

    let propertyToken =
      expect(tokens, i, tkIdentifier, "Expected property identifier")

    case propertyToken.value
    of "x":
      parseX(tokens, i, circle)
    of "y":
      parseY(tokens, i, circle)
    of "radius":
      parseRadius(tokens, i, circle)
    of "rotation":
      parseRotation(tokens, i, circle)
    of "centered":
      parseCentered(tokens, i, circle)
    of "color":
      parseColor(tokens, i, circle)
    else:
      error("Unknown property", propertyToken)

    discard expect(tokens, i, tkSemi, "Expected ';'")

  discard expect(tokens, i, tkRBrace, "Expected '}'")
  return circle

proc parseDiamond(tokens: seq[Token], i: var int): DiamondElement =
  var diamond = DiamondElement()

  discard expect(tokens, i, tkLBrace, "Expected '{'")

  while true:
    let nextToken = peek(tokens, i)
    if nextToken.kind == tkRBrace:
      break

    let propertyToken =
      expect(tokens, i, tkIdentifier, "Expected property identifier")

    case propertyToken.value
    of "x":
      parseX(tokens, i, diamond)
    of "y":
      parseY(tokens, i, diamond)
    of "width":
      parseWidth(tokens, i, diamond)
    of "height":
      parseHeight(tokens, i, diamond)
    of "rotation":
      parseRotation(tokens, i, diamond)
    of "centered":
      parseCentered(tokens, i, diamond)
    of "color":
      parseColor(tokens, i, diamond)
    else:
      error("Unknown property", propertyToken)

    discard expect(tokens, i, tkSemi, "Expected ';'")

  discard expect(tokens, i, tkRBrace, "Expected '}'")
  return diamond

proc parseRectangle(tokens: seq[Token], i: var int): RectangleElement =
  var rect = RectangleElement()

  discard expect(tokens, i, tkLBrace, "Expected '{'")

  while true:
    let nextToken = peek(tokens, i)
    if nextToken.kind == tkRBrace:
      break

    let propertyToken =
      expect(tokens, i, tkIdentifier, "Expected property identifier")

    case propertyToken.value
    of "x":
      parseX(tokens, i, rect)
    of "y":
      parseY(tokens, i, rect)
    of "width":
      parseWidth(tokens, i, rect)
    of "height":
      parseHeight(tokens, i, rect)
    of "rotation":
      parseRotation(tokens, i, rect)
    of "centered":
      parseCentered(tokens, i, rect)
    of "color":
      parseColor(tokens, i, rect)
    else:
      error("Unknown property", propertyToken)

    discard expect(tokens, i, tkSemi, "Expected ';'")

  discard expect(tokens, i, tkRBrace, "Expected '}'")
  return rect

proc parseStripes(tokens: seq[Token], i: var int): StripesElement =
  var stripes = StripesElement()

  discard expect(tokens, i, tkLBrace, "Expected '{'")

  while true:
    let nextToken = peek(tokens, i)
    if nextToken.kind == tkRBrace:
      break

    let propertyToken = expect(tokens, i, tkIdentifier, "Expected identifier")
    case propertyToken.value
    of "x":
      parseX(tokens, i, stripes)
    of "y":
      parseY(tokens, i, stripes)
    of "width":
      parseWidth(tokens, i, stripes)
    of "height":
      parseHeight(tokens, i, stripes)
    of "rotation":
      parseRotation(tokens, i, stripes)
    of "centered":
      parseCentered(tokens, i, stripes)
    of "colors":
      discard expect(tokens, i, tkLBracket, "Expected '['")

      let nextToken = peek(tokens, i)
      if nextToken.kind == tkRBracket:
        break

      while true:
        let colorToken = expect(tokens, i, tkColor, "Expected color")
        stripes.colors.add(colorFromHex(colorToken.value))
        if peek(tokens, i).kind == tkRBracket:
          break
        discard expect(tokens, i, tkComma, "Expected ','")

      discard expect(tokens, i, tkRBracket, "Expected ']'")

      if stripes.colors.len == 0:
        error("Expected at least one color", tokens[i])

    else:
      error("Unknown property", propertyToken)

    discard expect(tokens, i, tkSemi, "Expected ';'")

  discard expect(tokens, i, tkRBrace, "Expect '}'")


  return stripes

proc parse*(tokens: seq[Token]): Flag =
  var
    flag: Flag
    name: string = "default"
    verticalProportion: uint = 1
    horizontalProportion: uint = 1
    elements: seq[Element] = @[]

  var i = 0

  discard expect(tokens, i, tkFlag, "Expected 'flag'")
  name = expect(tokens, i, tkString, "Expected flag name").value
  discard expect(tokens, i, tkLBrace, "Expected '{'")

  while true:
    let nextToken = peek(tokens, i)
    if nextToken.kind == tkRBrace:
      break

    let identifierToken = expect(tokens, i, tkIdentifier, "Expected identifier")

    case identifierToken.value
    of "proportion":
      let verticalProportionToken = expect(tokens, i, tkNumber, "Expected number")
      verticalProportion = parseUInt(verticalProportionToken)

      discard expect(tokens, i, tkColon, "Expected ':'")

      let horizontalProportionToken = expect(tokens, i, tkNumber, "Expected number")
      horizontalProportion = parseUInt(horizontalProportionToken)

      discard expect(tokens, i, tkSemi, "Expected ';'")
    of "stripes":
      let stripes = parseStripes(tokens, i)
      elements.add(stripes)
    of "rectangle":
      let rect = parseRectangle(tokens, i)
      elements.add(rect)
    of "circle":
      let circle = parseCircle(tokens, i)
      elements.add(circle)
    of "diamond":
      let diamond = parseDiamond(tokens, i)
      elements.add(diamond)
    else:
      error("Unknown element type", identifierToken)

  discard expect(tokens, i, tkRBrace, "Expect '}'")

  flag = Flag(
    name: name,
    proportion: (vertical: verticalProportion, horizontal: horizontalProportion),
    elements: elements,
  )
  return flag
