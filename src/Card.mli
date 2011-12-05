
(** A simple module for cards where the sides are strings... eventually parameterizing
    by the sides would be wise *)

(** The type of cards *)
type t

(** The lone accessor function *)
val side : int -> t -> string

(** The lone creation function *)
val of_list : string list -> t
