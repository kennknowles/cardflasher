
open Architecture
open Printf

module Make(CardBox : CARDBOX) = struct
  module CardBox = CardBox

  class gtk_gui_signaler initbox =
  object(self)
    val mutable current_level = 0
    val mutable flipped = false
    val mutable listeners = []
    val mutable box = initbox

    method private set_box newbox = box <- newbox

    (* This adds a function to be called whenever the state is changed *)
    method add_listener f = listeners <- f :: listeners
      
    method private notify level = 
      List.iter (fun f -> f level) listeners
        
    (* Just directly expose the cardbox to listeners *)
    method box = box

    method level = current_level
      
    method set_level level =
      flipped <- false;
      current_level <- level;
      self # notify current_level
        
    method flipped = flipped
      
    method flip = 
      flipped <- not flipped;
      self # notify current_level
        
    method shuffle =
      self # set_box (CardBox.shuffle (self#box));
      for i = (CardBox.min_level self#box) to (CardBox.max_level self#box) do
        self # notify i
      done

    method correct =
      if CardBox.count ~level:current_level self#box > 0 then (
        self # set_box (CardBox.correct ~level:current_level self#box);
        flipped <- false;
        self # notify current_level;
        self # notify (current_level + 1)
      )
                
    method incorrect =
      if CardBox.count ~level:current_level self#box > 0 then (
        self # set_box (CardBox.incorrect ~level:current_level self#box);
        flipped <- false;
        self # notify current_level;
        self # notify 0
      )
  end
    
  let set_all_to_color widget color =
    List.iter
      (fun state ->
         widget # misc # modify_base [state, `WHITE];
         widget # misc # modify_bg [state, `WHITE])
      [`ACTIVE; `INSENSITIVE; `NORMAL; `PRELIGHT; `SELECTED]
      
  class level_button_manager signaler level_callback =
    let scrolled_window = GBin.scrolled_window ~hpolicy:`NEVER () in
    let button_vbox = GPack.vbox 
      ~packing:scrolled_window # add_with_viewport () in
    let make_label level count = sprintf "Level %i: %i" level count in
    
    let make_button ?group level =
      let button = GButton.radio_button 
        ?group
        ~packing:(button_vbox#pack ~expand:false ~fill:false)
        ~label:(make_label
                  level
                  (CardBox.count ~level signaler#box))
        ()
      in
      ignore (button # connect # clicked 
                ~callback:(fun () -> level_callback level));
      button
    in
    
    let first_button = make_button 0 in
    let group = first_button # group in
    let maximum = CardBox.max_level signaler#box in
  object(self)
    val mutable max = maximum
    val mutable radio_buttons = Array.init (maximum+1)
      (fun i -> 
         if i = 0 
         then first_button
         else make_button ~group i)
      
    (* Precondition: the level is no more than one greater than
       max; we can only go up one cardbox at a time. *)
    method update level =
      assert (level <= max+1);
      if level > max then
        let new_button = make_button ~group level in
        max <- level;
        radio_buttons <- Array.append radio_buttons [| new_button |]
      else
        radio_buttons.(level) # set_label 
          (make_label level
             (CardBox.count ~level signaler#box))
          
    method widget = scrolled_window
  end
    
  let card_view signaler =
    let cardbuffer = GText.buffer ~text:"Insert card here" () in
    let view = 
        GText.view
          ~editable:false
          ~buffer:cardbuffer
          ~justification:`CENTER
          ~wrap_mode:`WORD
          ()
    in
    
    (*set_all_to_color view (frame # misc # style # base `NORMAL);*)
    view # misc # modify_font (Pango.Font.from_string 
                                 (sprintf "Serif %i" !Config.font_size));
    (* should be unneccesary, since the whole window is
       double buffered: view # misc # set_double_buffered true; *)
    
    (* Add a callback to set the contents of the view to be
       correct no matter what just happened *)
    signaler # add_listener 
      (fun _ -> 
         let newtext =
           match CardBox.next ~level:signaler#level signaler#box with
           | None -> "(level is empty)"
           | Some (front, back) ->
               let strlist =
                 if signaler # flipped 
                 then back
                 else front
               in
               String.concat "\n" strlist
         in
         cardbuffer # set_text newtext);
    view
      
let card_control_area signaler =
  
  let vbox = GPack.vbox () in
  let frame = vbox in
  (*let frame = GPack.notebook ~show_tabs:false 
    ~packing:(vbox#pack ~expand:true ~fill:true) () in
  *)
  (*set_all_to_color frame `WHITE;*)
  (*frame # misc # style # set_base [`NORMAL, `WHITE];*)
  (* frame # misc # set_double_buffered true; *)
  
  let inner_vbox = GPack.vbox ~packing:frame#add () in
  
  let view = card_view signaler in
  
  inner_vbox # pack ~expand:true ~fill:false (view # coerce);
  
  let buttonbox = GPack.button_box 
    `HORIZONTAL 
    ~layout:`SPREAD
    ~packing:(vbox # pack) () 
  in
  
  (* And callbacks to switch the text contents, tell the
     cardbox object you got it correct or not, respectively *)
  let make_button label = GButton.button ~label ~packing:(buttonbox # add) () in
  
  let flip = make_button "Flip" in
  let correct = make_button "Correct" in
  let wrong = make_button "Wrong" in
  let shuffle = make_button "Shuffle" in
  let quit = make_button "Quit" in
  
  ignore [
    flip # connect # clicked ~callback:(fun () -> signaler # flip);
    correct # connect # clicked ~callback:(fun () -> signaler # correct);
    wrong # connect # clicked ~callback:(fun () -> signaler # incorrect);
    shuffle # connect # clicked ~callback:(fun () -> signaler # shuffle);
    quit # connect # clicked ~callback:GMain.Main.quit;
  ];
  
  vbox

let cardbox_area signaler =
  let button_manager = new level_button_manager 
    signaler
    (signaler # set_level)
  in
  
  signaler # add_listener (button_manager # update);
  button_manager # widget
    
let main_window signaler = 
  let window = GWindow.window () in
  let hbox = GPack.hbox ~packing:window#add () in
  
  let cardbox_area = cardbox_area signaler in
  let card_control_area = card_control_area signaler in
  
  hbox # pack (cardbox_area # coerce);
  hbox # pack ~expand:true ~fill:true (card_control_area # coerce);
  
  window
    
let main ?(level = 0) box =
  let _ = GtkMain.Main.init () in 
  
  let signaler = new gtk_gui_signaler box in
  
  let window = main_window signaler in
  
  (* It is ugly, but at least there is no flicker ;_; *)
  set_all_to_color window `WHITE;
  
  ignore (window # connect # destroy
            ~callback:(fun () -> 
                         Debug.debug "Closing window\n";
                         GMain.Main.quit ()));
  
  signaler # set_level level;
  window # misc # set_double_buffered true;
  window # show ();
  GMain.Main.main ();
  Debug.debug "Gtk halted";
  signaler # box;
end
