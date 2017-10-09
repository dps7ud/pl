type class_map = (string * ( (string * string * exp option) list)) list
and exp = string * string * exp_kind
and exp_kind =
    | Assign of string * exp
    | Bool of bool
    | Block of exp list
    | Case of exp * ((string * string * exp) list)
    | Dispatch of (exp option) * string * (exp list)
    | Divide of exp * exp
    | Eq of exp * exp
    | If of exp * exp * exp
    | Integer of Int32.t
    | Internal of string (*Object.copy &c.*)
    | Isvoid of exp
    | Le of exp * exp
             (*id      type     assign?             body*)
    | Let of (string * string * (exp option)) list * exp
    | Loop of exp * exp
    | Lt of exp * exp
    | Minus of exp * exp
    | New of string
    | Neg of exp
    | Not of exp
    | Plus of exp * exp
    | Self
    | String of string
    | Static of exp * string * string * (exp list)
    | Times of exp * exp
    | Variable of string

type imp_map = 
    (*cname,     mname*)
    ( (string * string)
    *
    (*formal list,  body*)
    ((string list) * exp) ) list

type parent_map = (string * string) list
type cool_address = int
type cool_value =
    | Cool_Int of Int32.t
    | Cool_Bool of bool
    | Cool_String of string * int
    | Cool_Object of string * ((string * cool_address) list)
    | Void

type environment = (string * cool_address) list
type store = (cool_address * cool_value) list
