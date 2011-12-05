%{

  open Architecture
  open Printf
  open Util

  let limit_sides n li =
    let rec limit_card n card =
      assert (n > 0);
      match n, card with
      | _, [] -> []
      | 1, _ -> [String.concat "\n" card]
      | _, hd::tl -> hd :: (limit_card (n-1) tl)
    in
    List.map (fun card -> {card with sides = limit_card n card.sides} ) li
%}

%token Blank_Line Side_Mark Record_Decl Metadata_Mark Card_Mark
%token<string> Text_Line 
%token<int> Simple_Decl
%token EOF

%type <int -> Util.parse_output list> deck

%start deck

%%

deck : deck_simple { $1 }
  
deck_simple : blanks simple_card_list deck_tail EOF
  { fun sides -> (limit_sides sides $2) @ $3 }
  
deck_record : blanks record_card_list deck_tail EOF { $2 @ $3 }
  
deck_tail : Record_Decl deck_record { $2 }
          | Simple_Decl deck_simple { $2 $1 }
          |                         { [] }

simple_card_list : simple_card some_blanks simple_card_list { $1 :: $3 }
          | simple_card { [$1] }
          |             { [] }

simple_card : Text_Line simple_card { {$2 with sides = $1 :: $2.sides} }
          | Text_Line { {sides = [$1]; metadata = []} }

record_card_list : record_card Card_Mark blanks record_card_list { $1 :: $4 }
          | { [] }

record_card : lines record_card_tail { {$2 with sides = (String.concat "\n" $1) :: $2.sides } }

record_card_tail : Side_Mark record_card { $2 }
                 | Metadata_Mark record_metadata { $2 }
                 |  { {sides = []; metadata = []} }

record_metadata  : Text_Line record_metadata { {$2 with metadata = $1::$2.metadata} }
                 | { {sides = []; metadata = []} }

lines            : Text_Line more_lines { $1::$2 }

more_lines       : Text_Line more_lines  { $1 :: $2 }
                 | Blank_Line more_lines { [""] }
                 |                       { [] }

blanks : blanks Blank_Line { }
                 | { }

some_blanks : Blank_Line blanks { }
