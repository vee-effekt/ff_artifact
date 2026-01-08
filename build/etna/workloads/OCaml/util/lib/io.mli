val bmain :
  seed:string ->
  out_channel ->
  test:string ->
  properties:(string * 'a Runner.property) list ->
  strategy:string ->
  strategies:(string * 'a Runner.basegen) list ->
  unit

val main :
  (string * 'a Runner.property) list ->
  (string * 'a Runner.basegen) list ->
  unit

val etna :
  (string * 'a Runner.property) list ->
  (string * 'a Runner.basegen) list ->
  unit

val timeout : int ref