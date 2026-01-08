open Util.Runner
open Util.Io
open RBT.Type
open RBT.Test
open Core
open RBT.Spec
open RBT

let () =
  let random_a = Splittable_random.State.of_int 1 in
  let random_b = Splittable_random.State.of_int 1 in
  let random_c = Splittable_random.State.of_int 1 in
  let random_d = Splittable_random.State.of_int 1 in
  let size = 10 in
  for _ = 1 to 10 do
    printf "\n";
    printf "\n";
    let v1 = Base_quickcheck.Generator.generate BaseType.quickcheck_generator ~size ~random:random_a in
    let v2 = Base_quickcheck.Generator.generate BaseType_Staged_SR.quickcheck_generator ~size ~random:random_b in
    let v3 = Base_quickcheck.Generator.generate BaseType_Staged_C.quickcheck_generator ~size ~random:random_c in
    let v4 = Base_quickcheck.Generator.generate BaseType_Staged_CSR.quickcheck_generator ~size ~random:random_d in
    printf "========= generator ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke.sexp_of_t v1));
    printf "========= Staged generator ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_SR.sexp_of_t v2));
    printf "========= Staged generator C ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_C.sexp_of_t v3));
    printf "========= Staged generator CSR ==========\n";
    printf "%s\n" (Sexp.to_string_hum (BaseBespoke_Staged_CSR.sexp_of_t v4))
  done

let properties : (string * rbt property) list =
  [
    ("prop_InsertValid", test_prop_InsertValid);
    ("prop_DeleteValid", test_prop_DeleteValid);
    ("prop_InsertPost", test_prop_InsertPost);
    ("prop_DeletePost", test_prop_DeletePost);
    ("prop_InsertModel", test_prop_InsertModel);
    ("prop_DeleteModel", test_prop_DeleteModel);
    ("prop_InsertInsert", test_prop_InsertInsert);
    ("prop_InsertDelete", test_prop_InsertDelete);
    ("prop_DeleteInsert", test_prop_DeleteInsert);
    ("prop_DeleteDelete", test_prop_DeleteDelete);
  ]

let bstrategies : (string * rbt basegen) list =
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
