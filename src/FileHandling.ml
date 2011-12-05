open Architecture
open Util
open Printf


module Make
  (CardBox : CARDBOX)
  (Parser  : PARSER with module Data = CardBox.Data) 
  (Output  : OUTPUT with module Data = CardBox.Data) 
  =
struct
  module CardBox = CardBox
  module Parser = Parser
  module Data = CardBox.Data
  module Quiz = CardBox.Quiz

  let cache_deck = ref Data.empty
  let cache_digest = ref ""
  
  let get_data () =
    let datafile = data_filename () in
    (* Check if it is the same as when we last loaded *)
    if (Digest.file datafile) = !cache_digest then
        !cache_deck
    else (
      cache_digest := Digest.file datafile;
      cache_deck := with_infile datafile Parser.parse_data;
      !cache_deck
    )
      
      
  (** Loads the level data for the deck given, so any
      data in the deck will be overwritten by the data in the
      ~/.cardflasher/data file *)
  let load_data quiz =
    CardBox.create (get_data ()) quiz
    
  let mv_f file1 file2 = 
    if Sys.file_exists file1 then (
      Debug.verbose (sprintf "Moving %s to %s\n" file1 file2);
      Sys.rename file1 file2
    )
    else
      Debug.verbose (sprintf "mv_f: File %s doesn't exist\n" file1)

  let rm_f file = if Sys.file_exists file then Sys.remove file

  (* I'm hard-coding 20 backups *)
  let shift_backups () =
    rm_f (backup_filename 20);
    for i = -19 to -1 do
      let num = -i in
      mv_f (backup_filename num) (backup_filename (num+1))
    done
    
  (** Saves the new level data for the deck, overwriting only
      the appropriate entries in the dotfile *)
  let save_data box =
    let prev_data = get_data () in
    let new_data = CardBox.commit prev_data box in
    
    shift_backups ();
    let datafile = data_filename () in
    let backup = backup_filename 1 in
    Sys.rename datafile backup;
    with_outfile datafile (fun outchan -> Output.output_data outchan new_data);
    
    (* Check that the output still parses! *)
    try ignore (with_infile datafile Parser.parse_data)
    with _ -> 
      eprintf "Yikes!  The very data I saved is unparseable, reverting to backup\n%!";
      Sys.rename datafile (backup_filename (-1));
      Sys.rename (backup_filename 1) datafile 

end
