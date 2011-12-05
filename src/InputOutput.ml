open Architecture
open Printf
open Util

module Input(Data : DATA) = struct
  module Data = Data
  module Entry = Data.Entry

  let parse_deck inchan =
    let lexbuf = Lexing.from_channel inchan in
    let records = (Parser.deck Lexer.nextline lexbuf) 3 in
    Debug.verbose (sprintf "Read %i cards\n" (List.length records));
    List.map (fun r -> 
                Debug.debug (sprintf "Card has %i sides!\n%!" (List.length r.sides));
                r.sides) 
      records 
      
  let nths indices li = List.map (List.nth li) indices

  let ws    = Str.regexp "[ \t]+"
  let colon = Str.regexp "[ \t]*:[ \t]*"

  let process_metadata_line set (data:Data.t) (metaline:string) =
    match Str.split colon metaline with
    | [] | [_] | _::_::_::_ -> failwith "Too many colons in metadata"
    | [given_str; level] ->
        let indices = List.map int_of_string (Str.split ws given_str) in
        let given = StringSet.of_list 
          (nths indices (StringSet.elements set)) in
        match List.map int_of_string (Str.split ws level) with
        | [level] -> Data.set_level ~given set level data
        | [] -> failwith "No level in metadata"
        | _ -> failwith "Some kind of noise in metadata"

  let parse_data inchan =
    let lexbuf = Lexing.from_channel inchan in
    let records = (Parser.deck Lexer.nextline lexbuf) 100 in

    List.fold_left
      (fun (data:Data.t) r ->
         let set = StringSet.of_list r.sides in
         List.fold_left (process_metadata_line set) data r.metadata)
      Data.empty
      records
end

module Output(Data : DATA) = struct
  module Data = Data
  module Entry = Data.Entry

  let output_data outchan data =
    let output_entry outchan entry =
      (* We turn the given info into a list of integers *)
      let sides = StringSet.elements (Data.Entry.sides entry) in
      fprintf outchan "\n%s\n" (String.concat "\n%%\n" sides);
      output_string outchan "%==%\n";
      Data.Entry.iter
        (fun given level -> 
           let strs = StringSet.elements given in
           if strs <> [] then 
             let indices = 
               List.map (fun s -> string_of_int (index_of s sides)) strs
             in
             fprintf outchan "%s : %i\n" (String.concat " " indices) level)
        entry;
      output_string outchan "%%%%\n"
    in
    output_string outchan "%%RECORD";
    Data.iter (output_entry outchan) data

  let output_deck outchan deck =
    (*let lengths = List.map List.length deck in *)
    (* let max = List.fold_left max lengths in *)
    
    List.iter 
      (fun card ->
         fprintf outchan "%s" (String.concat "\n%%\n" card);
         fprintf outchan "\n%%%%%%%%\n")
      deck
end
