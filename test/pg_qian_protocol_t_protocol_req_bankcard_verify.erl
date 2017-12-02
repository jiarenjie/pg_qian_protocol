%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Jan 2017 3:57 PM
%%%-------------------------------------------------------------------
-module(pg_qian_protocol_t_protocol_req_bankcard_verify).
-compile({parse_trans, exprecs}).
-author("simon").
-include_lib("mixer/include/mixer.hrl").
-behavior(pg_convert).
-behavior(pg_protocol).
-behaviour(pg_mcht_protocol).

%% API
%% callbacks of mcht_protocol
-mixin([{pg_mcht_protocol, [
  pr_formatter/1
  , in_2_out_map/0
]}]).

%% callbacks of pg_convert
-export([
  convert_config/0
]).
%% API
%% callbacks of pg_protocol
-export([
  sign_fields/0
  , options/0
%%  , to_list/1
]).

%%-------------------------------------------------------------------
-define(P, ?MODULE).

-record(?P, {
  mcht_id = 9999 :: pg_mcht_protocol:mcht_id()
  , txn_date = <<>> :: pg_mcht_protocol:txn_date()
  , txn_time = <<>> :: pg_mcht_protocol:txn_time()
  , txn_seq = <<"9999">> :: pg_mcht_protocol:txn_seq()
  , signature = <<"9">> :: pg_mcht_protocol:signature()
  , bank_card_no = <<>> :: pg_mcht_protocol:bank_card_no()
  , id_no = <<>> :: pg_mcht_protocol:id_type()
  , id_name = <<>> :: pg_mcht_protocol:id_name()
  , mobile = <<>> :: pg_mcht_protocol:mobile()
%%  , txn_type = bankcard_verify
%%  , txn_status = waiting :: pg_mcht_protocol:txn_status()
}).

-type ?P() :: #?P{}.
-export_type([?P/0]).
-export_records([?P]).

%%-------------------------------------------------------------------
sign_fields() ->
  sign_fields(dict_order).

sign_fields(doc_order) ->
  [
    mcht_id
    , txn_date
    , txn_seq
    , txn_time
%%    , txn_amt
%%    , order_desc
%%    , back_url
    , bank_card_no
%%    , id_type
    , id_no
    , id_name
    , mobile

  ];
sign_fields(dict_order) ->
  [
    bank_card_no
    , id_no
    , id_name
%%    , id_type
    , mcht_id
%%    , order_desc
    , mobile
%%    , txn_amt
    , txn_date
    , txn_seq
    , txn_time
%%    , back_url

  ].

options() ->
  #{
    channel_type => mcht,
    txn_type => bankcard_verify,
    direction => req
  }.


convert_config() ->
  [
    {save_req,
      [

        {to, {fun pg_mcht_protocol:repo_module/1, [mcht_txn_log]}},
        {from,
          [
            {?MODULE,
              [
                {txn_type, {static, collect}}
                , {txn_status, {static, waiting}}
                , {mcht_index_key, pg_mcht_protocol, mcht_index_key}
              ]
            },
            {?MODULE, all}
          ]}
      ]
    }

  ].


