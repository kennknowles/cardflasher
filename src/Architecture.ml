open Util

module type ENTRY = sig
  type t

  val create : StringSet.t -> t
  val sides  : t -> StringSet.t

  (** [add_level given entry] asserts that when the
      [given] items are known, the rest can be produced.
      Creates a new entry reflecting this assertion. *)
  val set_level : StringSet.t -> int -> t -> t

  (** [get_level given entry] returns the level at which 
      this entry should be quizzed when [given] is the
      hint *)
  val get_level : StringSet.t -> t -> int
  val iter : (StringSet.t -> int -> unit) -> t -> unit
end

module type DATA = sig
  module Entry : ENTRY

  type t

  (** Extensions of ENTRY functions to incorporate
      searching a collection of entries *)
  val set_level : given:StringSet.t -> StringSet.t -> int -> t -> t
  val get_level : given:StringSet.t -> StringSet.t -> t -> int
    
  (** Basic constructors *)
  val empty : t
  val add_entry : Entry.t -> t -> t
  val iter : (Entry.t -> unit) -> t -> unit
end

module type PARSER = sig
  module Data : DATA
  val parse_data : in_channel -> Data.t
  val parse_deck : in_channel -> string list list
end

module type OUTPUT = sig
  module Data : DATA
  val output_data : out_channel -> Data.t -> unit
  val output_deck : out_channel -> string list list -> unit
end

module type QUIZ = sig
  (** Cards are simply tuples of strings *)
  type card = string list 

  (** And decks are simply lists of cards *)
  type deck = card list
  
  type t

  (** [empty given_indices] creates a quiz 
      where [given indices] indicates the elements of
      any card added to it that will be known to the quizee *)
  val create : int list -> deck -> t
  val deck   : t -> deck

  val count  : t -> int
  val next   : t -> (card * card) option
  val pop    : t -> t
  val add    : card * card -> t -> t
  val append : t -> t -> t
  val fold   : (card * card -> 'a -> 'a) -> t -> 'a -> 'a
  val shuffle : t -> t
end
  
module type CARDBOX = sig
  module Data : DATA
  module Quiz : QUIZ

  type t

  val empty : t

  (** A cardbox is a synergy of a quiz and official data for the
      levels of the cards in the quiz *)
  val create : Data.t -> Quiz.t -> t

  (** Commit merges the cardbox info with the data and
      outputs new data, which may be written to a file etc. *)
  val commit : Data.t -> t -> Data.t

  (** This commit uses the data with which the cardbox was
      constructed *)
  val commit_internal : t -> Data.t

  val quiz : ?level:int -> t -> Quiz.t

(*  val add   : ?level:int -> card -> t -> t
  val nth   : ?level:int -> int -> t -> Card.t *)
  val count : ?level:int -> t -> int
  val min_level : t -> int
  val max_level : t -> int
  val shuffle   : ?level:int -> t -> t
  val next : level:int -> t -> (Quiz.card * Quiz.card) option
  val correct   : level:int -> t -> t
  val incorrect : level:int -> t -> t
end

module type UI = sig
  module CardBox : CARDBOX

  val main : ?level:int -> CardBox.t -> CardBox.t
end
