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

  Token* = object
    kind: TokenKind
    value: string

func isSpace(ch: char): bool =
  return ch in {' ', '\t', '\n'}

func tokenize*(src: string): seq[Token] =
  var tokens: seq[Token] = @[]
  var i = 0

  while i < src.len:
    let ch = src[i]

    if ch.isSpace:
      inc(i)
      continue
    elif ch == '{':
      tokens.add(Token(kind: tkLBrace, value: "{"))
      inc(i)
    elif ch == '}':
      tokens.add(Token(kind: tkRBrace, value: "}"))
      inc(i)
    elif ch == '[':
      tokens.add(Token(kind: tkLBracket, value: "["))
      inc(i)
    elif ch == ']':
      tokens.add(Token(kind: tkRBracket, value: "]"))
      inc(i)
    elif ch == ':':
      tokens.add(Token(kind: tkColon, value: ":"))
      inc(i)
    elif ch == ';':
      tokens.add(Token(kind: tkSemi, value: ";"))
      inc(i)
    elif ch == '(':
      tokens.add(Token(kind: tkLParen, value: "("))
      inc(i)
    elif ch == ')':
      tokens.add(Token(kind: tkRParen, value: ")"))
      inc(i)
    elif ch == ',':
      tokens.add(Token(kind: tkComma, value: ","))
      inc(i)
    elif ch == '"':
      inc(i)
      var str = ""
      while i < src.len and src[i] != '"':
        str.add(src[i])
        inc(i)
      if i < src.len and src[i] == '"':
        inc(i)
      tokens.add(Token(kind: tkString, value: str))
    elif ch.isDigit:
      var numStr = ""
      while i < src.len and src[i].isDigit:
        numStr.add(src[i])
        inc(i)
      tokens.add(Token(kind: tkNumber, value: numStr))
    else:
      var str = ""
      while i < src.len and not src[i].isSpace and not (src[i] in {'{', '}', '[', ']', ':', ';', '(', ')', '"', ','}):
        str.add(src[i])
        inc(i)
      if str == "flag":
        tokens.add(Token(kind: tkFlag, value: str))
      else:
        tokens.add(Token(kind: tkIdentifier, value: str))
  
  tokens.add(Token(kind: tkEOF, value: ""))
  return tokens
