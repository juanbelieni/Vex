import strutils

type
  TokenKind* = enum
    tkFlag
    tkString
    tkNumber
    tkLBrace
    tkRBrace
    tkLParen
    tkRParen
    tkLBracket
    tkRBracket
    tkColon
    tkSemi
    tkIdentifier
    tkComma
    tkEOF
    tkUnknown
    tkColor

  Token* = object
    kind*: TokenKind
    value*: string
    line*: int
    column*: int

func isSpace(ch: char): bool =
  return ch in {' ', '\t', '\n'}

func isHexDigit(ch: char): bool =
  return ch in {'0' .. '9', 'a' .. 'f', 'A' .. 'F'}

func tokenize*(src: string): seq[Token] =
  var tokens: seq[Token] = @[]
  var i = 0
  var line = 1
  var column = 1

  while i < src.len:
    let ch = src[i]

    if ch.isSpace:
      if ch == '\n':
        inc(line)
        column = 1
      else:
        inc(column)
      inc(i)
      continue
    elif ch == '{':
      tokens.add(Token(kind: tkLBrace, value: "{", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == '}':
      tokens.add(Token(kind: tkRBrace, value: "}", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == '[':
      tokens.add(Token(kind: tkLBracket, value: "[", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == ']':
      tokens.add(Token(kind: tkRBracket, value: "]", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == ':':
      tokens.add(Token(kind: tkColon, value: ":", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == ';':
      tokens.add(Token(kind: tkSemi, value: ";", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == '(':
      tokens.add(Token(kind: tkLParen, value: "(", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == ')':
      tokens.add(Token(kind: tkRParen, value: ")", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == ',':
      tokens.add(Token(kind: tkComma, value: ",", line: line, column: column))
      inc(i)
      inc(column)
    elif ch == '"':
      let startColumn = column
      inc(i)
      inc(column)
      var str = ""
      while i < src.len and src[i] != '"':
        str.add(src[i])
        inc(i)
        inc(column)
      if i < src.len and src[i] == '"':
        inc(i)
        inc(column)
      tokens.add(Token(kind: tkString, value: str, line: line, column: startColumn))
    elif ch.isDigit:
      let startColumn = column
      var numStr = ""
      while i < src.len and (src[i].isDigit or src[i] == '.'):
        numStr.add(src[i])
        inc(i)
        inc(column)
      tokens.add(Token(kind: tkNumber, value: numStr, line: line, column: startColumn))
    elif ch == '#':
      let startColumn = column
      var colorStr = "#"
      inc(i)
      inc(column)
      while i < src.len and isHexDigit(src[i]):
        colorStr.add(src[i])
        inc(i)
        inc(column)
      if colorStr.len == 7 or colorStr.len == 4: # Assuming #RRGGBB format
        tokens.add(
          Token(kind: tkColor, value: colorStr, line: line, column: startColumn)
        )
      else:
        tokens.add(
          Token(kind: tkUnknown, value: colorStr, line: line, column: startColumn)
        )
    else:
      let startColumn = column
      var str = ""
      while i < src.len and not src[i].isSpace and
          not (src[i] in {'{', '}', '[', ']', ':', ';', '(', ')', '"', ','}):
        str.add(src[i])
        inc(i)
        inc(column)
      if str == "flag":
        tokens.add(Token(kind: tkFlag, value: str, line: line, column: startColumn))
      else:
        tokens.add(
          Token(kind: tkIdentifier, value: str, line: line, column: startColumn)
        )

  tokens.add(Token(kind: tkEOF, value: "", line: line, column: column))
  return tokens
