import token
import expressions
import ereport

type
  Parser* = ref object
    tokens*: seq[Token] = @[]
    current*: int = 0


proc comparison(p: Parser): Expr
    
proc peek(p: Parser): Token = 
  return p.tokens[p.current]


proc throwError(p: Parser, message: string) = 
  if p.peek().kind == TokenKind.kEOF:
    report(p.peek().line, " at end", message)
  else:
    report(p.peek().line, " at '" & p.peek().lexeme & "'", message)
  raise newException(ValueError, message)



proc isAtEnd(p: Parser): bool =
  return p.peek().kind == TokenKind.kEOF


proc previous(p: Parser): Token = 
  return p.tokens[p.current - 1]


proc check(p: Parser, kind: TokenKind): bool =
  if p.isAtEnd(): return false
  
  return p.peek().kind == kind


proc advance(p: Parser): Token = 
  if not p.isAtEnd():
    p.current += 1
  return p.previous()


proc match(p: Parser, kinds: varargs[TokenKind]): bool =
  for k in kinds:
    if p.check(k):
      discard p.advance()
      return true
  return false
  
proc equality(p: Parser): Expr = 
  var exp = p.comparison()
  
  while (p.match(TokenKind.BangEqual, TokenKind.EqualEqual)):
    let op = p.previous()
    let right = p.comparison()
    exp = Expr(kind: ExprKind.exprBinary, left: exp,
                       right: right, 
                       operator: op
                       )
  return exp

  
proc expression(p: Parser): Expr =
  return p.equality()

  
proc consume(p: Parser, kind: TokenKind, message: string): Token =
  if p.check(kind): return p.advance()
  else: p.throwError(message)

  
proc primary(p: Parser): Expr = 
  if p.match(TokenKind.kFalse): return Expr(kind: ExprKind.exprLiteral, value: "false")
  if p.match(TokenKind.kTrue): return Expr(kind: ExprKind.exprLiteral, value: "true")
  if p.match(TokenKind.kNil): return Expr(kind: ExprKind.exprLiteral, value: "nil")
  
  if p.match(TokenKind.Number, TokenKind.String):
    return Expr(kind: ExprKind.exprLiteral, value: p.previous().literal)
    
  if p.match(TokenKind.LeftParen):
    var exp = p.expression()
    discard p.consume(TokenKind.RightParen, "Expect ')' after expression.")
    return Expr(kind: ExprKind.exprGrouping, expression: exp)
  
  p.throwError("Expect expression")

  

proc unary(p: Parser): Expr = 
  if p.match(TokenKind.Bang, TokenKind.Minus):
    let op = p.previous()
    let right = p.unary()
    return Expr(kind: ExprKind.exprUnary, right: right, operator: op)
  return p.primary()


proc factor(p: Parser): Expr =
  var exp = p.unary()
  
  while p.match(TokenKind.Slash, TokenKind.Star):
    let op = p.previous()
    let right = p.unary()
    exp = Expr(kind: ExprKind.exprBinary, left: exp,
                       right: right, 
                       operator: op
                       )
  return exp

proc term(p: Parser): Expr = 
  var exp = p.factor()
  
  while p.match(TokenKind.Minus, TokenKind.Plus):
    let op = p.previous()
    let right = p.factor()
    exp = Expr(kind: ExprKind.exprBinary, left: exp,
                       right: right, 
                       operator: op
                       )
  return exp


proc comparison(p: Parser): Expr = 
  var exp = p.term()
  
  while p.match(TokenKind.Greater, TokenKind.GreaterEqual, TokenKind.Less, TokenKind.LessEqual):
    let op = p.previous()
    let right = p.term()
    exp = Expr(kind: ExprKind.exprBinary, left: exp,
                       right: right, 
                       operator: op
                       )
  return exp

proc parse*(p: Parser): Expr = 
  echo "Begin parsing"
  try:
    return p.expression()
  except ValueError:
    echo "Error! Does not compute!"
    return nil


proc synchronize(p: Parser) = 
  discard p.advance()
  
  while not p.isAtEnd():
    if p.previous().kind == TokenKind.Semicolon: return
    
    case p.peek().kind
      of TokenKind.kClass: return
      of TokenKind.kFun: return
      of TokenKind.kVar: return
      of TokenKind.kFor: return
      of TokenKind.kIf: return
      of TokenKind.kWhile: return
      of TokenKind.kPrint: return
      of TokenKind.kReturn: return
      else:
        discard p.advance()
