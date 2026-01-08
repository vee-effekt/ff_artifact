open STLC.Test
open Util.Io
open Util.Runner
open STLC.Type_defn;;
open STLC
open Core;;
(*
let () =
  let random_a = Splittable_random.State.of_int 1 in
  let random_b = Splittable_random.State.of_int 1 in
  let random_c = Splittable_random.State.of_int 1 in
  let random_d = Splittable_random.State.of_int 1 in
  let size = 10 in
  for _ = 1 to 10 do
    printf "\n";
    printf "\n";
    let v1 = Base_quickcheck.Generator.generate BaseBespoke.quickcheck_generator ~size ~random:random_a in
    let v2 = Base_quickcheck.Generator.generate BaseBespoke_Staged_SR.quickcheck_generator ~size ~random:random_b in
    let v3 = Base_quickcheck.Generator.generate BaseBespoke_Staged_C.quickcheck_generator ~size ~random:random_c in
    let v4 = Base_quickcheck.Generator.generate BaseBespoke_Staged_CSR.quickcheck_generator ~size ~random:random_d in
    printf "========= generator ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_C.sexp_of_t v1));
    printf "========= Staged generator ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_C.sexp_of_t v2));
    printf "========= Staged generator C ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_C.sexp_of_t v3));
    printf "========= Staged generator CSR ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_C.sexp_of_t v4))
  done
*)
(* RUNNER COMMAND:
   dune exec STLC -- qcheck prop_SinglePreserve bespoke out
   dune exec STLC -- qcheck prop_SinglePreserve type out
   dune exec STLC -- crowbar prop_SinglePreserve bespoke out
   dune exec STLC -- crowbar prop_SinglePreserve type out
   dune exec STLC -- afl prop_SinglePreserve bespoke out
   dune exec STLC -- afl prop_SinglePreserve type out
   dune exec STLC -- base prop_SinglePreserve bespoke out
   dune exec STLC -- base prop_SinglePreserve type out
*)
(*
let () =
  let random_a = Splittable_random.State.of_int 1 in
  let random_b = Splittable_random.State.of_int 1 in
  let random_c = Splittable_random.State.of_int 1 in
  let random_d = Splittable_random.State.of_int 1 in
  let size = 10 in
  for _ = 1 to 10000 do
    printf "\n";
    printf "\n";
    let gen1 = Base_quickcheck.Generator.generate BaseType.quickcheck_generator ~size ~random:random_a in
    let gen2 = Base_quickcheck.Generator.generate BaseType_Staged_SR.quickcheck_generator ~size ~random:random_b in
    let gen3 = Base_quickcheck.Generator.generate BaseType_Staged_C.quickcheck_generator ~size ~random:random_c in
    let gen4 = Base_quickcheck.Generator.generate BaseType_Staged_CSR.quickcheck_generator ~size ~random:random_d in
    printf "========= type generator ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseType.sexp_of_t gen1));
    printf "========= staged generator ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseType_Staged_SR.sexp_of_t gen1));
    printf "========= staged generator c ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseType_Staged_C.sexp_of_t gen1));
    printf "========= staged generator csr ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseType_Staged_CSR.sexp_of_t gen1));
  done
*)

let properties : (string * expr property) list =
  [
    ("prop_SinglePreserve", test_prop_SinglePreserve);
    ("prop_MultiPreserve", test_prop_MultiPreserve);
  ]

  let bstrategies : (string * expr basegen) list =
    [
      ("bespoke", (module BaseBespoke));
      ("bespokeStaged", (module BaseBespoke_Staged_SR));
      ("bespokeStagedC", (module BaseBespoke_Staged_C));
      ("bespokeStagedCSR", (module BaseBespoke_Staged_CSR));
      ("type", (module BaseType));
      ("staged", (module BaseType_Staged_SR));
      ("stagedC", (module BaseType_Staged_C));
      ("stagedCSR", (module BaseType_Staged_CSR))
    ]
  
let () = main properties bstrategies
