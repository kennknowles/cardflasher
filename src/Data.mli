open Architecture

module Make : functor(Entry : ENTRY) -> DATA with module Entry = Entry

