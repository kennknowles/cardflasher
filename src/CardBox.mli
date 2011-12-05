open Architecture

module Make : 
  functor(Data : DATA) -> 
    functor(Quiz : QUIZ) -> 
      CARDBOX with module Data = Data and module Quiz = Quiz
    
