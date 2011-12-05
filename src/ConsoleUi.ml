open Architecture
open Printf

module Make(CardBox : CARDBOX) = struct
  module CardBox = CardBox

  let saved_box = ref CardBox.empty

  exception Quit
  let rec get_response () =
    match read_line () with
    | "y" | "Y" -> true
    | "n" | "N" -> false
    | "q" | "Q" -> raise Quit
    | _ -> 
        printf "Please input 'y' or 'n'\n";
        get_response ()
          
  let do_card front back = 
    List.iter print_endline front;
    print_endline "> Press Enter";
    ignore (read_line ());
    List.iter print_endline back;
    print_endline "> Correct? (y/n) or q to quit ";
    let response = get_response () in printf "\n"; response
      
  let rec main ?(level = 0) box =
    let rec do_quiz ~level box =
      saved_box := box;
      match CardBox.next ~level box with
      | None -> box
      | Some (front, back) ->
          if do_card front back 
          then do_quiz ~level (CardBox.correct ~level box)
          else do_quiz ~level (CardBox.incorrect ~level box)
    in

    (* Paranoid checks to make sure there is some quiz going on *)
    printf "Level %i: %!" level;
    match CardBox.next ~level box with
    | None -> printf "Empty!\n%!";
        if level < CardBox.max_level box 
        then main ~level:(level+1) box
        else if CardBox.count box > 0 
        then main ~level:0 box
        else failwith "ConsoleUi.main: Completely empty deck!"
    | Some _ ->
        printf "Quizzing\n\n%!";
        try do_quiz ~level box
        with Quit -> !saved_box

end
