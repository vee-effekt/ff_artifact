open Util.Limits
open Type

type t = rbt [@@deriving sexp, quickcheck]

let quickcheck_generator =
  let open Base_quickcheck.Generator in
  list (both (Nat.quickcheck_generator_parameterized rbt_bespoke_limits) (Nat.quickcheck_generator_parameterized rbt_bespoke_limits))
  >>= fun l -> Base.List.fold l ~init:E ~f:insert_correct |> return
