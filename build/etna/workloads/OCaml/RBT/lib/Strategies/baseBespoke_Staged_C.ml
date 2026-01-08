open Util.Limits
open Type
open Fast_gen;;
module G = Fast_gen.Staged_generator.MakeStaged(Fast_gen.C_random)
open G
open Let_syntax

type t = rbt [@@deriving sexp, quickcheck]
  
let staged_code =
  bind 
    (list (map2 (Nat.staged_quickcheck_generator_c_t (G.C.lift rbt_bespoke_limits)) (Nat.staged_quickcheck_generator_c_t (G.C.lift rbt_bespoke_limits)) 
              ~f:(fun x y -> G.C.pair x y)))
    ~f:(fun l -> return .< repeat_insert .~l >.)
    
let quickcheck_generator = G.jit ~extra_cmi_paths:["/home/ubuntu/etna2/workloads/OCaml/RBT/_build/default/lib/.RBT.objs/byte"] staged_code
