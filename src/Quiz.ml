open Printf

type card = string list
type deck = card list

type t = (card * card) list

let split_nths indices li =
  let rec split i li =
    match li with
    | hd::tl ->
        let chosen, not_chosen = split (i+1) tl in
        if List.mem i indices 
        then hd::chosen, not_chosen
        else chosen, hd::not_chosen
    | [] -> [], []
  in
  split 0 li
;;
        
let filter quiz =
  let newquiz = List.filter (fun (front, back) -> List.length front > 0) quiz in
  let len_old, len_new = List.length quiz, List.length newquiz in
  if len_old > len_new then 
    eprintf "Warning: Dropped %i cards which had no hints\n%!" (len_old - len_new);
  newquiz
      

let create given_sides deck =
  filter (List.map (split_nths given_sides) deck)

let deck quiz = 
  List.map (fun (a,b) -> a @ b) quiz

let add card quiz =
  quiz @ (filter [card])

let next quiz =
  match quiz with
  | [] -> None
  | hd::_ -> Some hd

let count quiz = List.length quiz

let shuffle quiz =
  let size = count quiz in
  let quiz_array = Array.of_list quiz in

  (* Shuffle the array of indices *)
  for i = 0 to size - 1 do
    let j = i + (Random.int (size - i)) in
    let tmp = quiz_array.(i) in
    quiz_array.(i) <- quiz_array.(j);
    quiz_array.(j) <- tmp
  done;

  Array.to_list quiz_array

let pop quiz = 
  match quiz with
  | [] -> []
  | hd::tl -> tl

(* Unbeknownst to outsiders, this eliminates duplicates *)
let append quiz1 quiz2 = 
  quiz1 @ (List.filter (fun c -> not (List.mem c quiz1)) quiz2)

let fold f quiz init =
  List.fold_right f quiz init
