import token



type
  ExprKind = enum
    exprBinary,
    exprGrouping,
    exprLiteral,
    exprUnary
  Expr* = ref object of RootObj
    someval: string
    right*: Expr
    operator*: Token
    case kind: ExprKind
    of exprBinary:
      left*: Expr
      #right*: Expr
      #operator*: Token
    of exprGrouping:
      expression*: Expr
    of exprLiteral:
      value*: string
    of exprUnary:
      discard
      #operator*: Token
      #right*: Expr
    

proc printExpr(e: Expr): string = 
  case e.kind: 
  of exprBinary:
    var result = "( " & e.operator.lexeme
    result = result & " " & printExpr(e.left)
    result = result & " " & printExpr(e.right) & ")"
    return result
  of exprGrouping:
    var result = "( group "
    result = result & printExpr(e.expression) & ")"
    return result
  of exprLiteral:
      return e.value
  of exprUnary:
      return "( " & e.operator.lexeme & " " & printExpr(e.right) & ")"


var unar = Expr(kind: ExprKind.exprUnary, operator: Token(kind: TokenKind.Minus, lexeme: "-"), right: Expr(kind: ExprKind.exprLiteral, value: "123"))
var grp = Expr(kind: ExprKind.exprGrouping, expression: Expr(kind: ExprKind.exprLiteral, value:"45.67"))
var myexp = Expr(kind: ExprKind.exprBinary, left: unar,
                       right: grp, 
                       operator: Token(kind: TokenKind.Star, lexeme: "*")
                       )

echo printExpr(myexp)