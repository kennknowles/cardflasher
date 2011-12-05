open Printf

module StringSet = struct
  include Set.Make(struct type t= string let compare = compare end)
    
  let of_list li =
    List.fold_right add li empty
end

module IntMap = Map.Make(struct type t = int let compare = compare end)
module StringSetMap = Map.Make(StringSet)
module IntListMap = Map.Make(struct type t = int list
                                    let compare = compare end)
type parse_output = {
  sides : string list;
  metadata : string list;
}  
   


let with_infile filename f =
  let inchan = open_in filename in
  let result = f inchan in
  close_in inchan;
  result

let with_outfile filename f =
  let outchan = open_out filename in
  let result = f outchan in
  close_out outchan;
  result

module Unix = UnixLabels

let dotdir = Filename.concat (Sys.getenv "HOME") ".cardflasher"

let config_file = Filename.concat dotdir "config"
let data_file = Filename.concat dotdir "data"

let ensure_conf_exists () =
    if not (Sys.file_exists dotdir) then
        Unix.mkdir dotdir ~perm:0o755;

    if not (Sys.file_exists config_file) then
        close_out(open_out config_file);

    if not (Sys.file_exists data_file) then
        close_out(open_out data_file)

let config_filename () = ensure_conf_exists (); config_file
let data_filename () = ensure_conf_exists (); data_file
let backup_filename i = 
  ensure_conf_exists (); 
  sprintf "%s~%i" (data_filename ()) i


let index_of elem li =
  let rec indexof i elem li =
    match li with
    | [] -> raise Not_found
    | x::tl ->
        if x = elem then i else indexof (i+1) elem tl
  in
  indexof 0 elem li
