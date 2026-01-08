open Spec
open Util
open Runner
open Nat
open Type;;

let ( << ) f g x = f (g x)

let test_prop_InsertValid : rbt property =
  {
    name = "test_prop_InsertValid";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.triple generator (module Nat) (module Nat))
          (bmake << prop_InsertValid) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_InsertValid. *)

let test_prop_DeleteValid : rbt property =
  {
    name = "test_prop_DeleteValid";
    b =
      (fun ~generator ~name ~seed ->
        bbuild (Core_plus.double generator (module Nat)) (bmake << prop_DeleteValid) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_DeleteValid. *)

let test_prop_InsertPost : rbt property =
  {
    name = "test_prop_InsertPost";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.quad generator (module Nat) (module Nat) (module Nat))
          (bmake << prop_InsertPost) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_InsertPost. *)

let test_prop_DeletePost : rbt property =
  {
    name = "test_prop_DeletePost";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.triple generator (module Nat) (module Nat))
          (bmake << prop_DeletePost) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_DeletePost. *)

let test_prop_InsertModel : rbt property =
  {
    name = "test_prop_InsertModel";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.triple generator (module Nat) (module Nat))
          (bmake << prop_InsertModel) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_InsertModel. *)

let test_prop_DeleteModel : rbt property =
  {
    name = "test_prop_DeleteModel";
    b =
      (fun ~generator ~name ~seed ->
        bbuild (Core_plus.double generator (module Nat)) (bmake << prop_DeleteModel) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_DeleteModel. *)

let test_prop_InsertInsert : rbt property =
  {
    name = "test_prop_InsertInsert";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.quinta generator
             (module Nat)
             (module Nat)
             (module Nat)
             (module Nat))
          (bmake << prop_InsertInsert) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_InsertInsert. *)

let test_prop_InsertDelete : rbt property =
  {
    name = "test_prop_InsertDelete";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.quad generator (module Nat) (module Nat) (module Nat))
          (bmake << prop_InsertDelete) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_InsertDelete. *)

let test_prop_DeleteInsert : rbt property =
  {
    name = "test_prop_DeleteInsert";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.quad generator (module Nat) (module Nat) (module Nat))
          (bmake << prop_DeleteInsert) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_DeleteInsert. *)

let test_prop_DeleteDelete : rbt property =
  {
    name = "test_prop_DeleteDelete";
    b =
      (fun ~generator ~name ~seed ->
        bbuild
          (Core_plus.triple generator (module Nat) (module Nat))
          (bmake << prop_DeleteDelete) ~seed:(Some seed) ~name);
  }

(*! QCheck test_prop_DeleteDelete. *)
