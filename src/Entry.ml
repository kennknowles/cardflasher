open Util
open Printf

type t = {
  sides  : StringSet.t;
  levels : int StringSetMap.t;
}

let sides entry = entry.sides

let create sides = {sides=sides; levels = StringSetMap.empty}

let get_level given entry =
  assert (StringSet.subset given entry.sides);
  try  StringSetMap.find given entry.levels
  with Not_found -> 0

let set_level given level entry =
  assert (StringSet.subset given entry.sides);

  Debug.debug (sprintf "Setting something to level %i\n" level);

  let initial_change = StringSetMap.add given level entry.levels in
  {entry with levels = initial_change }
(*
  This needs more careful consideration - and more global analysis will be
  more useful anyhow. 
  { entry with levels =
      StringSetMap.mapi
        (fun db_given db_level ->
           if StringSet.subset db_given given
           then min db_level level
           else if StringSet.subset given db_given 
           then max db_level level
           else db_level)
        initial_change }
*)

let iter f entry = StringSetMap.iter f entry.levels
