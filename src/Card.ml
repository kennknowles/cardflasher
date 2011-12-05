
module StringSet = Set.Make(String)
module IntSet = Set.Make(Int)

module SidesMap = Map.Make(struct
                             type t = int list
                             let compare = compare
                           end)

type card = {
  data   : StringSet.t;   (** The set of strings, implicitly sorted *)

  (** For a certain set of given info, the card has a level *)
  levels : int SidesMap.t
}

let add_entry s data = StringSet.add s data
let entries data = StringSet.elements data

(* makes a set of integers from the setof data *)
let inverse_lookup card data =
  card.data

let level lev given card =
  try SidesMap.find given

let side n card = nth n card

let of_list cardlist = cardlist
