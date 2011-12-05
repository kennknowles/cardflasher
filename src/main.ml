open Util
open Architecture
open Printf

module DataM      = Data.Make(Entry)
module InputM     = InputOutput.Input(DataM)
module OutputM    = InputOutput.Output(DataM)
module CardBoxM   = CardBox.Make(DataM)(Quiz)
module FilesM     = FileHandling.Make(CardBoxM)(InputM)(OutputM)
  
let ui_list = ref [];;

(* Our trusty basic UI *)
module ConsoleUiM = ConsoleUi.Make(CardBoxM);;
let () = ui_list := ("console", ConsoleUiM.main) :: !ui_list;;

(* Our uglier less trusty UI *)
IFDEF GTK THEN module GtkUiM     = GtkUi.Make(CardBoxM) END
IFDEF GTK THEN let () = ui_list := ("gtk", GtkUiM.main) :: !ui_list END

let summarize box =
  for i = CardBoxM.min_level box to CardBoxM.max_level box do
    let count = CardBoxM.count ~level:i box in
    if count > 0 then printf "Level %i: %i\n" i count
  done

let cheat from level box =
  assert (level >= 0);
  let box = ref box in
  for i = from to level-1 do
    while
      match CardBoxM.next ~level:i !box with
      | None -> false
      | Some _ -> box := CardBoxM.correct ~level:i !box; true
    do () done
  done;
  !box

let dispatch quiz =
  if Quiz.count quiz = 0 then
    (eprintf "No deck/empty deck specified!\n"; exit 1)
  else (
    Debug.debug (
      sprintf "We have a quiz with %i cards, the first of which has %i sides\n%!"
        (Quiz.count quiz) 
        (match Quiz.next quiz with 
         | None -> failwith "poo" 
         | Some (front,back) -> List.length front)
    );
    
    let box = FilesM.load_data quiz in

    (* Cheating is easy so let us do it and exit *)
    if !Config.cheat_to > 0 then (
      FilesM.save_data (cheat !Config.cheat_from !Config.cheat_to box); 
      exit 0
    );
    
    (* Remember to shuffle after loading data because the 
       current load_data puts things in the order they exist in
       the data file.  This should be changed to only
       merge in scores. *)
    let box = 
      if !Config.shuffle then (Debug.verbose "Shuffling...\n"; CardBoxM.shuffle box) else box in
    
    match !Config.dump with
    | `Deck -> OutputM.output_deck stdout (Quiz.deck quiz)
    | `Data -> OutputM.output_data stdout (CardBoxM.commit_internal box)
    | `Summary -> summarize box
    
    | _ ->
        let ui_main = match !Config.ui with
        | "" -> snd (List.hd !ui_list)
        | ui  -> 
            try List.assoc ui !ui_list
            with Not_found -> eprintf "Unknown UI '%s'" ui; exit 1
        in
        let newbox = ui_main ~level:!Config.level box in
        FilesM.save_data newbox
  )

let input_deckfile filename =
  try with_infile filename InputM.parse_deck
  with Stream.Error errmsg ->
    eprintf "When trying to load deckfile '%s': %s\n%!"
      filename errmsg;
    exit 1
    
      
let () = 
  Random.self_init ();
  Config.load_from_file (fst (List.split !ui_list));
  Config.load_from_argv (fst (List.split !ui_list));

  Debug.verbose (Config.summarize_options ());
  
  (* First just read in the decks *)
  let decks = 
    List.map (fun s -> with_infile s InputM.parse_deck) !Config.filenames in
  
  (* Then turn then into quizzes *)
  let quizzes = List.map (Quiz.create !Config.given) decks in
  

  (* The only case in which I don't merge all the decks is when we
     are dumping a summary of each *)
  match !Config.each, !Config.dump with
  | true, `Summary ->
      List.iter 
        (fun (filename, quiz) ->
           let box = FilesM.load_data quiz in
           printf "----- %s -----\n%!" filename;
           summarize box)
        (List.combine !Config.filenames quizzes)
        
  | true, _ -> 
      eprintf "The --each option is invalid without --dump summary"; exit 1

  | _ ->
    let mondo_quiz = 
      List.fold_left
        Quiz.append 
        (Quiz.create [] [])
        quizzes
    in
    dispatch mondo_quiz

