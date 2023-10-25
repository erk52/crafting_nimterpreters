import token
import std/strformat
import std/strutils
import std/tables
import ereport

var keywordTable = initTable[string, TokenKind]()
keywordTable["and"] = TokenKind.kAnd
keywordTable["class"] = TokenKind.kClass
keywordTable["else"] = TokenKind.kElse
keywordTable["false"] = TokenKind.kFalse
keywordTable["for"] = TokenKind.kFor
keywordTable["fun"] = TokenKind.kFun
keywordTable["if"] = TokenKind.kIf
keywordTable["nil"] = TokenKind.kNil
keywordTable["or"]= TokenKind.kOr
keywordTable["print"]= TokenKind.kPrint
keywordTable["return"]= TokenKind.kReturn
keywordTable["super"]= TokenKind.kSuper
keywordTable["this"]= TokenKind.kThis
keywordTable["true"]= TokenKind.kTrue
keywordTable["var"]= TokenKind.kVar
keywordTable["while"]= TokenKind.kWhile

type
  Scanner* = ref object
    source*: string
    tokens*: seq[Token]
    start: int
    current: int
    line: int
    
proc isAtEnd(s: Scanner): bool = 
  return s.current >= len(s.source)
  
proc advance(s: Scanner): char = 
  result = s.source[s.current]
  s.current += 1
  
proc addToken(s: Scanner, tkind: TokenKind) = 
  s.tokens.add(Token(kind: tkind, literal: ""))
  
proc addToken(s: Scanner, tkind: TokenKind, lit: string) = 
  s.tokens.add(Token(kind: tkind, literal: lit, lexeme: s.source[s.start .. s.current-1]))

proc match(s: Scanner, expected: char, ): bool =
  if s.isAtEnd(): return false
  if s.source[s.current] != expected: return false
  s.current += 1
  return true

proc peek(s: Scanner): char = 
  if s.isAtEnd(): return '\0'
  return s.source[s.current]
  
proc peekNext(s: Scanner): char = 
  if s.current + 1 >= s.source.len:
    return '\0'
  return s.source[s.current + 1]

proc string(s: Scanner) = 
  while s.peek() != '"' and not s.isAtEnd():
    if (s.peek() == '\n'):
      s.line += 1
    discard s.advance()
  
  if s.isAtEnd():
    error(s.line, "Unterminated string.")
  discard s.advance()
  let val = s.source[s.start+1 .. s.current-2]
  s.addToken(TokenKind.String, val)

proc number(s: Scanner) = 
  while isDigit(s.peek()):
    discard s.advance()
  if (s.peek() == '.' and isDigit(s.peekNext())):
    discard s.advance()
    while (isDigit(s.peek())):
      discard s.advance()
  let lex = s.source[s.start .. s.current-1]
  s.addToken(TokenKind.Number, lex)
  
proc identifier(s: Scanner) = 
  while isAlphaNumeric(s.peek()):
    discard s.advance()
  let text = s.source[s.start .. s.current-1]
  let kind = keywordTable.getOrDefault(text, TokenKind.Identifier)
  
  s.addToken(kind, text)

proc scanToken(s: Scanner) = 
  let c = s.advance()
  case c
    of '(': s.addToken(TokenKind.LeftParen)
    of ')': s.addToken(TokenKind.RightParen)
    of '{': s.addToken(TokenKind.LeftBrace)
    of '}': s.addToken(TokenKind.RightBrace)
    of ',': s.addToken(TokenKind.Comma)
    of '.': s.addToken(TokenKind.Dot)
    of '-': s.addToken(TokenKind.Minus, "-")
    of '+': s.addToken(TokenKind.Plus, "+")
    of ';': s.addToken(TokenKind.Semicolon, ";")
    of '*': s.addToken(TokenKind.Star, "*")
    of '!': 
      if s.match('='): 
        s.addToken(TokenKind.BangEqual, "!=")
      else:
       s.addToken(TokenKind.Bang, "!")
    of '=': 
      if s.match('='): 
        s.addToken(TokenKind.EqualEqual, "==")
      else: 
        s.addToken(TokenKind.Equal, "=")
    of '<': 
      if s.match('='):
        s.addToken(TokenKind.LessEqual, "<=")
      else: 
        s.addToken(TokenKind.Less, "<")
    of '>': 
      if s.match('='):
        s.addToken(TokenKind.GreaterEqual, ">=")
      else:
        s.addToken(TokenKind.Greater, ">")
    of '/':
      if s.match('/'):
        while s.peek() != '\n' and not s.isAtEnd():
          discard s.advance()
      else:
        s.addToken(TokenKind.Slash, "/")
    of ' ', '\r', '\t': discard
    of '"': s.string()
    else:
      if isDigit(c):
        s.number()
      elif isAlphaAscii(c) or c == '_':
        s.identifier()
      else:
        error(s.line, fmt"Unrecognized token")
        return

    
proc scanTokens*(s: Scanner): seq[Token] = 
  while not s.isAtEnd():
    s.start = s.current
    s.scanToken()

  let eof_token = Token(kind: TokenKind.kEOF, lexeme: "", literal: "", line: s.line)
  s.tokens.add(eof_token)
  return s.tokens
  
