open Runner
open Parse

(* global timeout in seconds for test threads *)
let timeout = ref 60

let brun (p : 'a property) (g : 'a basegen) ~seed : unit = p.b ~generator:g ~name:p.name ~seed:seed ()

let bmain ~seed oc ~test ~properties ~strategy ~strategies =
  let prop = lookup properties test in
  let gen = lookup strategies strategy in
  match (prop, gen) with
  | None, _ -> Printf.printf "Test %s not found\n" test
  | _, None -> Printf.printf "Strategy %s not found\n" strategy
  | Some prop, Some gen ->
      let start_time = Unix.gettimeofday () in
      brun prop gen ~seed;
      let end_time = Unix.gettimeofday () in
      Printf.fprintf oc "[exit ok, %f duration %s]\n" (end_time -. start_time) seed;
      (* Printf.fprintf oc "[%f end %s]\n" end_time seed; *)
      flush oc
  
(* piping helper functions *)



  let _simple_fork f file =
    Printf.printf "Timeout value: %d seconds\n" !timeout; (* Debugging timeout value *)
    let oc = open_out_gen [ Open_wronly; Open_append; Open_creat ] 0o666 file in
    Printf.fprintf oc "[start]\n";
    flush oc;
    match Unix.fork () with
    (* runner/child thread *)
    | 0 ->
        f oc
        (* todo: if the forking overhead is too much, we could pipe the endtime back to the main thread *)
    | pid -> (
        match Unix.fork () with
        | 0 ->
            (* timeout thread *)
            Unix.sleep !timeout;
            Unix.kill pid Sys.sigalrm
        | pid' -> (
            (* waiting thread *)
            let _, status = Unix.waitpid [] pid in
            Unix.kill pid' Sys.sigterm;
            match status with
            | Unix.WEXITED _ -> ()
            | Unix.WSIGNALED c when c = Sys.sigalrm ->
                Printf.fprintf oc "[exit timeout]\n"
            | _ -> Printf.fprintf oc "[exit unexpected]\n"));
            flush oc
  
let base_fork ~seed ~test ~properties ~strategy ~strategies = _simple_fork (fun oc ->
  bmain ~seed oc ~test ~properties ~strategy ~strategies)

(* Call format:
   dune exec <workload> -- <framework> <testname> <strategy> <filename>
   for example,
   dune exec BST -- qcheck prop_InsertValid bespokeGenerator out.txt
   or
   dune exec BST -- crowbar prop_InsertPost crowbarType out2.txt
*)
let main (props : (string * 'a property) list)
     
    (bstrats : (string * 'a basegen) list) : unit =
  if Array.length Sys.argv < 5 then
    match Unix.getenv "framework" with
    | _ ->
        print_endline
          "Not enough arguments were passed. Could not determine whether this \
           was a child process."
  else
    let framework = Sys.argv.(1) in
    let testname = Sys.argv.(2) in
    let strategy = Sys.argv.(3) in
    let filename = Sys.argv.(4) in
    let seed = Sys.argv.(5) in
    Printf.printf
      "Executing test %s into file %s using strategy %s on framework %s, with seed %s\n"
      testname filename strategy framework seed;
    flush stdout;
    match framework with
    | "base" ->
        print_endline "Valid framework Base_quickcheck\n";
        base_fork ~seed ~test:testname ~properties:props ~strategy ~strategies:bstrats filename
    | _ -> print_endline ("Framework " ^ framework ^ " was not found\n")

let etna = main