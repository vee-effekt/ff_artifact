open Util.Limits
open Type;;
open Fast_gen;;
open Core;;
open Core_unix;;

module G = Fast_gen.Staged_generator.MakeStaged(Fast_gen.Sr_random)

  type t = Type.rbt [@@deriving sexp, quickcheck]

  let staged_quickcheck_generator_color =
    G.weighted_union
      [((.< 1.  >.), (G.return (.< R  >.)));
      ((.< 1.  >.), (G.return (.< B  >.)))]
      
  let staged_code =
    G.recursive (G.C.lift ())
      (fun go ->
         fun _ ->
           let _pair__015_ = ((.< 1.  >.), (G.return (.< E  >.)))
           and _pair__016_ =
             ((.< 1.  >.),
               (G.bind G.size
                  ~f:(fun _size__012_ ->
                        G.with_size ~size_c:(G.C.pred _size__012_)
                          (G.bind (G.recurse go (G.C.lift ()))
                             ~f:(fun _x__017_ ->
                                   G.bind
                                     (Nat.staged_quickcheck_generator_sr_t (G.C.lift rbt_type_limits))
                                     ~f:(fun _x__018_ ->
                                           G.bind
                                             (Nat.staged_quickcheck_generator_sr_t (G.C.lift rbt_type_limits))
                                             ~f:(fun _x__019_ ->
                                                   G.bind
                                                     (G.recurse go
                                                        (G.C.lift
                                                          ()))
                                                     ~f:(fun
                                                          _x__020_
                                                          ->
                                                          G.bind
                                                          staged_quickcheck_generator_color
                                                          ~f:(
                                                          fun
                                                          _x__021_
                                                          ->
                                                          G.return
                                                          (.<
                                                          T
                                                          ((.~_x__021_),
                                                          (.~_x__020_),
                                                          (.~_x__019_),
                                                          (.~_x__018_),
                                                          (.~_x__017_)) 
                                                          >.)))))))))) in
           let _gen__013_ = G.weighted_union [_pair__015_]
           and _gen__014_ =
             G.weighted_union [_pair__015_; _pair__016_] in
           G.bind G.size
             ~f:(fun x -> G.if_z x _gen__013_ _gen__014_))
  let quickcheck_generator = G.jit ~extra_cmi_paths:["/home/ubuntu/etna2/workloads/OCaml/RBT/_build/default/lib/.RBT.objs/byte"] staged_code
  
  let sexp_of_t = sexp_of_t