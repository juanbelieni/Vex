import tokenizer
import flag
import std/strutils
import std/strformat

proc error(message: string, token: Token) =
  echo fmt"Error: {message} at token: {token.value} of kind {token.kind}"
  quit(1)

proc peek(tokens: seq[Token], i: int): Token =
  if i >= tokens.len:
    return Token(kind: tkEOF, value: "")
  else:
    return tokens[i]

proc expect(tokens: seq[Token], i: var int, kind: TokenKind, message: string): Token =
  let token = peek(tokens, i)
  if token.kind == kind:
    inc(i)
    return token
  else:
    error(message, token)

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

    case identifierToken.value:
    of "proportion":
      verticalProportion = expect(tokens, i, tkNumber, "Expected number").value.parseUInt()
      discard expect(tokens, i, tkColon, "Expected ':'")
      horizontalProportion = expect(tokens, i, tkNumber, "Expected number").value.parseUInt()
      discard expect(tokens, i, tkSemi, "Expected ';'")
    of "stripes":
      discard expect(tokens, i, tkLBrace, "Expected '{'")
      
      var colors = newSeq[Color]()

      while true:
        let nextToken = peek(tokens, i)
        if nextToken.kind == tkRBrace:
          break

        let identifierToken = expect(tokens, i, tkIdentifier, "Expected identifier")
        case identifierToken.value:
          of "colors":
            discard expect(tokens, i, tkLBracket, "Expected '['")

            let nextToken = peek(tokens, i)
            if nextToken.kind == tkRBracket:
              break

            while true:
              let colorToken = expect(tokens, i, tkColor, "Expected color")
              colors.add(colorFromHex(colorToken.value))
              if peek(tokens, i).kind == tkRBracket:
                break
              discard expect(tokens, i, tkComma, "Expected ','")
            discard expect(tokens, i, tkRBracket, "Expected ']'")
            discard expect(tokens, i, tkSemi, "Expected ';'")

      discard expect(tokens, i, tkRBrace, "Expect '}'")

      if colors.len == 0:
        error("Expected at least one color", identifierToken)      

      elements.add(StripesElement(colors: colors))
      

  discard expect(tokens, i, tkRBrace, "Expect '}'")

  flag = Flag(name: name, proportion: (vertical: verticalProportion, horizontal: horizontalProportion), elements: elements)
  return flag
