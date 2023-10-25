import os
import std/strformat
import token
import scanner
import expressions
import ereport
import parser

var script: string
var hadError: bool = false
  
#[
proc scanTokens(s: string): seq[Token] = 
  var result: seq[Token] = @[]
  result.add(Token(literal: s))
  return result
]#

proc run(s: string) = 
  var scan = Scanner(source: s)
  var tokens = scan.scanTokens()
  
  var parser = Parser(tokens: tokens)
  var exp = parser.parse()
  echo "Tokens: "
  for t in tokens:
    echo t.toString()

  echo exp.printExpr()
  

proc runFile(f: string) = 
  echo fmt"Loading script {f}"
  script = readFile(f)
  run(script)
  return
  
proc runPrompt() = 
  echo "Welcome to Lox REPL"
  while true:
    write(stdout, "-> ")
    let inp = readLine(stdin)
    if inp == "":
      break
    run(inp)
    hadError = false
  return

proc main() = 
  let args = commandLineParams()
  if len(args) > 1:
    echo "Too many arguments."
    return
  elif len(args) == 1:
    runFile(args[0])
  else:
    runPrompt()
    
  
main()