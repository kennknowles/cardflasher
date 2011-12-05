type dump = [`Deck | `Data | `Summary | `NoDump]
val filenames : string list ref
val dump : dump ref

val ui : string ref
val cheat_to : int ref
val cheat_from : int ref
val given : int list ref
val select : int list ref
val shuffle : bool ref
val each : bool ref
val level : int ref
val font_size : int ref

val debug : bool ref
val verbose : bool ref

(** [load_from_XXX usage] is the appropriate way to call these *)
val load_from_file : string list -> unit
val load_from_argv : string list -> unit
val summarize_options : unit -> string
