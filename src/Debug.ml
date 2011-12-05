open Printf

let verbose s = 
    if !Config.verbose then
        eprintf "%s%!" s
    else
        ()

let debug  s =
    if !Config.debug then
        eprintf "%s%!" s
    else
        ()
