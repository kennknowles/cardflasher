
module StringSet : sig
  include Set.S with type elt = string
  val of_list : string list -> t
  (* val nth_elements : int list -> string list *)
end

module IntMap : Map.S with type key = int
module StringSetMap : Map.S with type key = StringSet.t
module IntListMap : Map.S with type key = int list

type parse_output = {
  sides : string list;
  metadata : string list;
}

val with_infile : string -> (in_channel -> 'a) -> 'a
val with_outfile : string -> (out_channel -> 'a) -> 'a

val config_filename : unit -> string
val data_filename   : unit -> string
val backup_filename : int -> string

val index_of : 'a -> 'a list -> int
