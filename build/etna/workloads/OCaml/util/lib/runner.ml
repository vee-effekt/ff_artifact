(* the test type for Crowbar is just a lazy call to Crowbar.add_test *)
(* same with Base_quickcheck, but with Test.run  *)
type btest = unit -> unit

(* rename of the Core module type *)
type 'a basegen = (module Base_quickcheck.Test.S with type t = 'a)

(* Generalizing pre and post conditions *)
type test = Pre of bool * test | Post of bool

let ( =>> ) pre post = Pre (pre, post)
let ( ->> ) pre post = Pre (pre, Post post)

(* Generalizing parameterization of tests *)

type 'a property = {
  name : string;
  b : generator:'a basegen -> name:string -> seed:string -> btest;
}

let rec bmake (t : test) : unit Base.Or_error.t =
  match t with
  | Pre (true, post) ->
      (* Printf.printf "Processing Pre-condition: true\n"; *)
      bmake post
  | Pre (false, _) ->
      (* Printf.printf "Skipping test due to false pre-condition\n"; *)
      (* false precondition, we can skip test *)
      Ok ()
  | Post true ->
      (* Printf.printf "Post-condition passed: true\n"; *)
      Ok ()
  | Post false  ->
      (* Printf.printf "Post-condition failed: false\n"; *)
      Error (Base.Error.of_string "fail")

 let _verbose res =
  match res with
  | Ok () -> print_endline "Tests passed?"
  | Error (_,err) -> print_endline "bug found!";
                     print_endline (Base.Error.to_string_hum err)

let bbuild (type b) (g : b basegen) (f : b -> unit Base.Or_error.t) ?(seed : string option = None) : name:string -> btest =
  fun ~name:_ () ->
    let seed_config =
      match seed with
      | Some s when not (String.equal s "") ->
        Base_quickcheck.Test.Config.Seed.Deterministic s
      | _ -> Base_quickcheck.Test.Config.Seed.Nondeterministic
    in
    let module G = (val g : Base_quickcheck.Test.S with type t = b) in
    Base_quickcheck.Test.result ~f:(fun x ->
      let res = f x in
      match res with
      | Ok () -> Ok ()
      | Error _ ->  Error (Base.Error.of_string (Sexplib.Sexp.to_string_hum (G.sexp_of_t x)))
      ) g
      ~config:
        {
          seed = seed_config;
          test_count = Core.Int.max_value;
          shrink_count = 0;
          sizes = Base_quickcheck.Test.default_config.sizes;
        }
    |> _verbose
  
