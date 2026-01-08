open Core;;
open Nat;;

type color = R | B [@@deriving sexp, quickcheck]

type rbt = E | T of color * rbt * Nat.t * Nat.t * rbt
[@@deriving sexp, quickcheck]

let blacken_correct (t : rbt) : rbt =
  match t with E -> E | T (_, a, k, v, b) -> T (B, a, k, v, b)

let balance_correct (col : color) (tl : rbt) (k : Nat.t) (v : Nat.t)
    (tr : rbt) : rbt =
  match (col, tl, k, v, tr) with
  | B, T (R, T (R, a, x, vx, b), y, vy, c), z, vz, d ->
      T (R, T (B, a, x, vx, b), y, vy, T (B, c, z, vz, d))
  | B, T (R, a, x, vx, T (R, b, y, vy, c)), z, vz, d ->
      T (R, T (B, a, x, vx, b), y, vy, T (B, c, z, vz, d))
  | B, a, x, vx, T (R, T (R, b, y, vy, c), z, vz, d) ->
      T (R, T (B, a, x, vx, b), y, vy, T (B, c, z, vz, d))
  | B, a, x, vx, T (R, b, y, vy, T (R, c, z, vz, d)) ->
      T (R, T (B, a, x, vx, b), y, vy, T (B, c, z, vz, d))
  | rb, a, x, vx, b -> T (rb, a, x, vx, b)

let insert_correct s (k, vk) : rbt =
  let rec ins x vx t =
    match t with
    | E -> T (R, E, x, vx, E)
    | T (rb, a, y, vy, b) ->
        if x < y then balance_correct rb (ins x vx a) y vy b
        else if x > y then balance_correct rb a y vy (ins x vx b)
        else T (rb, a, y, vx, b)
  in
  blacken_correct (ins k vk s)

let repeat_insert (lst : (Nat.t * Nat.t) list) : rbt =
  List.fold_left ~f:insert_correct ~init:E lst
