open Architecture

module Make : 
  functor(CardBox : CARDBOX) ->
    functor(Parser : PARSER with module Data = CardBox.Data) ->
      functor(Output : OUTPUT with module Data = CardBox.Data) ->
        sig
          (** Loads the level data for the deck given, so any
              data in the deck will be overwritten by the data in the
              ~/.cardflasher/data file *)
          val load_data : CardBox.Quiz.t -> CardBox.t
            
          (** Saves the new level data for the deck, overwriting only
              the appropriate entries in the dotfile *)
          val save_data : CardBox.t -> unit
        end
