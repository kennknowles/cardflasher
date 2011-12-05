open Architecture

module Input  : functor(Data: DATA) -> PARSER with module Data = Data
module Output : functor(Data: DATA) -> OUTPUT with module Data = Data
