import std/strformat

type
  TokenKind* = enum
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    Comma,
    Dot,
    Minus,
    Plus,
    Semicolon,
    Slash,
    Star,
    Bang,
    BangEqual
    Equal,
    EqualEqual,
    Greater,
    GreaterEqual
    Less,
    LessEqual,
    Identifier,
    String,
    Number,
    kAnd,
    kClass,
    kElse,
    kFalse,
    kFun,
    kFor,
    kIf,
    kNil,
    kOr,
    kPrint,
    kReturn,
    kSuper,
    kThis,
    kTrue,
    kVar,
    kWhile,
    kEOF
    
  Token* = ref object
    kind*: TokenKind
    lexeme*: string
    literal*: string
    line*: int
    
proc toString*(t: Token): string = 
  return fmt"({t.lexeme}, {t.literal}, {t.kind})"
    