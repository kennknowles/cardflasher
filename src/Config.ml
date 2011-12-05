open Util
open Printf

type dump = [`Deck | `Data | `Summary | `NoDump ]
type ui = string

let filenames = ref []

(* NOTE: Relies on the Ui module or main to understand what empty string means*)
let ui = ref ""
let dump = ref `NoDump
let level = ref 0;;
let given = ref [0];;
let select = ref [];;
let shuffle = ref false;;
let each = ref false;;
let font_size = ref 16;;
let cheat_to = ref 0;;
let cheat_from = ref 0;;

let debug = ref false;;
let verbose = ref false;;

let usage = "Usage: cardflasher [options] [decks]"

let args ui_list = Arg.align [
  "--cheat-to", Arg.Set_int cheat_to,
  " Raise every card to at least this level, if it is above --cheat-from";

  "--cheat-from", Arg.Set_int cheat_from,
  " Level at which to begin cheating.";

  "--debug", Arg.Set debug,
  " Turn on debugging output; use this for bug reports!";
  
  "--dump", Arg.Symbol (["deck"; "data"; "summary"],
                        (function s ->
                           dump := (match s with
                                    | "deck" -> `Deck
                                    | "data" -> `Data
                                    | "summary" -> `Summary
                                    |  _ -> failwith "Invalid dump"))),
  " Dump the deck to an alternate format.";

  "--each", Arg.Set each,
  " Cause --dump summary to display per-file stats.";

  "--font-size", Arg.Set_int font_size,
  " Set the font size for the card view.";

  "--given", Arg.String (fun s ->
                           let sep = Str.regexp "[ \t,]+" in
                           given := List.map int_of_string (Str.split sep s)),
  " Space/comma separated list of which sides are the given hint.";
  
  "--level", Arg.Set_int level,
  " Choose the minimum box to start in, defaults to 0";

(*
  "--select", Arg.String (fun s ->
                            let sep = Str.regexp "[ \t,]+" in
                            select := List.map int_of_string (Str.split sep s)),
  " Limit the sides considered part of the quiz.";
*)

  "--shuffle", Arg.Set shuffle,
  " Before starting each level, shuffle the cards in that level.";

  "--ui", Arg.Symbol (ui_list, (fun s -> ui := s)),
  " Choose your UI from those compiled in.";

  "--verbose", Arg.Set verbose,
  " Turn on verbose output, a subset of the debug output.";
  
]

let rec read_whole_file inchan =
  let buf = Buffer.create 50 in
  while 
    try 
      Buffer.add_string buf (input_line inchan); 
      Buffer.add_char buf ' ';
      true
    with End_of_file -> false
  do () done;
  Buffer.contents buf

let ws = Str.regexp "[ \r\n\t]"
let load_from_file ui_list = 
  with_infile (config_filename ())
    (fun inchan ->
       let arglist = Sys.argv.(0) :: (Str.split ws (read_whole_file inchan)) in
       let argv = Array.of_list arglist in
       try
         let current = ref 0 in
         Arg.parse_argv ~current argv (args ui_list)
           (fun filename -> filenames := filename :: !filenames)
           usage
       with
       | Arg.Help _ -> Arg.usage (args ui_list) usage)
    
let load_from_argv ui_list =
  Arg.parse 
    (args ui_list)
    (fun filename -> filenames := filename :: !filenames)
    usage;
  filenames := List.rev !filenames

let summarize_options () =
  String.concat "\n" [
    sprintf "Cheat: %i" !cheat_to;
    sprintf "Debugging: %B" !debug;
    sprintf "Dump: %s"
      (match !dump with
       | `Deck -> "deck"
       | `Data -> "data"
       | `Summary -> "summary"
       | _ -> "none");
    sprintf "Each: %B" !each;
    sprintf "Font size: %i" !font_size;
    sprintf "Given: %s" (String.concat " " (List.map string_of_int !given));
    sprintf "Starting at level %i" !level;
    sprintf "Shuffle: %B" !shuffle;
    sprintf "Ui: %s" !ui;
    sprintf "Verbose: %B" !verbose;
]
