{
open Printf
open Util
open Parser
open Lexing
}

let ws = ['\t' ' ']
let digit = ['0' - '9']
let newline = ['\n' '\r']
let nonspecial = [^ '\r' '\n' '%']
let tail = nonspecial* newline
let notnewline = [^ '\n' '\r']

(* Since we start at the beginning of a line, we just need
   to be sure to always end at one or this will fuck up. *)
rule nextline = parse
  | "%%SIMPLE" ws (digit+ as num) tail       { Simple_Decl (int_of_string num) }
  | "%%RECORD" tail                          { Record_Decl }
  | "%%%%" tail                              { Card_Mark }
  | "%%" tail                                { Side_Mark }
  | "%==%" tail                              { Metadata_Mark }
  | "-" newline                              { Text_Line "" }
  | (nonspecial notnewline* as body) newline { Text_Line body }
  | newline                                  { Blank_Line }
  | eof                                      { EOF }
