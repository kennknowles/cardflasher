open Util
open Architecture
open Printf

module Make(Data: DATA)(Quiz: QUIZ) = struct
  module Quiz = Quiz
  module Data = Data
  
  type t = {
    quizzes   : Quiz.t IntMap.t;
    data : Data.t;
  }

  let empty = {
    quizzes = IntMap.empty;
    data = Data.empty;
  }
  
  let quiz ?level box =
    match level with
    | None ->
        IntMap.fold
          (fun _ subquiz accum_quiz -> Quiz.append accum_quiz subquiz)
          box.quizzes
          (Quiz.create [] [])
          
    | Some level ->
        try IntMap.find level box.quizzes
        with Not_found -> Quiz.create [] []

  let set_level ~given sides level data =
    Data.set_level ~given:(StringSet.of_list given) (StringSet.of_list sides)
      level data

  let get_level ~given sides data =
    Data.get_level ~given:(StringSet.of_list given) (StringSet.of_list sides)
      data

  let create data inputquiz =
    Quiz.fold
      (fun (front, back) box ->
         let level = get_level ~given:front (front@back) data in
         Debug.debug (sprintf "Card w/ %i sides is at level %i\n"
                        (List.length (front@back)) level);
         {box with quizzes =
             IntMap.add level 
               (Quiz.add (front,back) (quiz ~level:level box))
               box.quizzes} )
      inputquiz
      {quizzes = IntMap.empty; data = data}
  
  let commit data box =
    let commit_quiz level qu data =
      Quiz.fold 
        (fun (front, back) data ->
           Debug.debug (sprintf "Commit card w/  %i sides to level %i\n"
                          (List.length (front@back)) level);
           set_level ~given:front (front@back) level data)
        qu
        data
    in
    IntMap.fold commit_quiz box.quizzes data

  let commit_internal box =
    commit box.data box
      
  let count ?level box =
    Quiz.count (quiz ?level box)

  let shuffle ?level box =
    match level with
    | Some i -> ( {box with quizzes =
                      let shuffled = Quiz.shuffle (quiz ~level:i box) in
                      IntMap.add i shuffled box.quizzes} )
    | None ->
        {box with quizzes =
            IntMap.map (fun quiz -> Quiz.shuffle quiz) box.quizzes }

  let max_level box =
    IntMap.fold
      (fun level quiz max -> 
         if (level > max) && (Quiz.count quiz > 0) then level else max)
      box.quizzes
      0
      
  let min_level box =
    IntMap.fold
      (fun level quiz min -> 
         if (level < min) && (Quiz.count quiz > 0) then level else min)
      box.quizzes
      max_int

  let next ~level box = Quiz.next (quiz ~level box)

  let move_one_card ~source ~dest box =
    (* Note that the logic is a little hairy if
       source = dest, so I make it a special case. *)
    let source_quiz = quiz ~level:source box in
    match Quiz.next source_quiz with
    | None -> box
    | Some (known, unknown) ->
        let source_quiz = Quiz.pop source_quiz in
        let dest_quiz = Quiz.add (known, unknown)
          (if source = dest 
           then source_quiz 
           else quiz ~level:dest box)
        in
        
        {box with quizzes =
            IntMap.add dest dest_quiz
              (IntMap.add source source_quiz box.quizzes)}
          
  let correct ~level box = move_one_card level (level+1) box

  let incorrect ~level box = move_one_card level 0 box
end
