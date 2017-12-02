%%%-------------------------------------------------------------------
%%% @author simonxu
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Apr 2016 09:48
%%%-------------------------------------------------------------------
-author("simonxu").
-include("./type_binaries.hrl").

-type token() :: binary().
-type ip() :: binary().
-type mobile() :: byte11().
-type id_name() :: binary().
-type bank_card_no() :: byte16_21().
-type id_no() :: byte15() | byte18().
-type ret_desc() :: binary().
-type ret_code() :: non_neg_integer().
-type is_certify_bankcard() :: binary().

-export_type([
  token/0
  , ip/0
  , mobile/0
  , id_name/0
  , bank_card_no/0
  , id_no/0
  , ret_desc/0
  , ret_code/0
  , is_certify_bankcard/0
]).

