open Architecture

module Make : functor(CardBox:CARDBOX) -> UI with module CardBox = CardBox
