Cardflasher
===========

Cardflasher is an "n-sided" "card box" flashcard program, useful for learning
languages with pictographs, phonetic alphabest, and romanizations (Japanese,
Mandarin, etc).

In your card deck, you write down each "side" of the card, and then when you
study, you say what you want on the front and what you want on the back. 

Cardflasher automatically tracks your progress on all questions, moving them into a
separate box based on how many times you've gotten it right. Each combination of
front/back is a separate question, and cardflasher also recognizes duplicate
questions so you can put together as many custom decks as you like and it will
remember how well you did on a question anyhow.

I wrote this for myself to study Japanese, so it isn't too nicely packaged, nor
beautiful to look at, but it got me and a few others through four years :-)


Dependencies
------------

 * ocaml - Cardflasher is written in Objective Caml - you'll need it to build.
 * lablgtk - The OCaml bindings for Gtk, licensed LGPL >= 2.0


Build / Installation
--------------------

$ make
$ make install

If you are familiar with OCaml, you'll know that you can also build an optimized version.

$ make opt
$ make install-opt


Usage
-----

After building, try these commands out (substitution cardflasher.opt for the natively-compiled version)

$ cardflasher --help
$ cardflasher --ui console test_data/050_utf8
$ cardflasher --ui gtk test_data/050_utf8
$ cardflasher --shuffle --ui console --given 2 test_data/050_utf8

At some point, I had decks for all of the Genki series of books, but I seem to have misplaced them...
