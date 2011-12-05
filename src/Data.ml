open Util
open Architecture
open Printf

module Make(Entry : ENTRY) = struct
  module Entry = Entry
  
  type t = Entry.t StringSetMap.t

  let get_entry sides data =
    try StringSetMap.find sides data
    with Not_found -> Entry.create sides

  let get_level ~given sides data =
    Entry.get_level given (get_entry sides data)
      
  let set_level ~given sides level data =
    StringSetMap.add sides 
      (Entry.set_level given level (get_entry sides data))
      data

  let empty = StringSetMap.empty
  let add_entry entry data =
    StringSetMap.add (Entry.sides entry) entry data

  let iter f data = StringSetMap.iter (fun _ entry -> f entry) data

  (* Normalizing the data means that for every
     pair of subentries (f1,b1) and (f2,b2),
     if (f1 <= f2) and (b1 >= b2) then
     the level of (f1, b1) should be less than the
     level of (f2, b2).

     Whether this means raising one or lowering the other
     depends on which was more recent... hmmm

  let normalize data =
*)

end
