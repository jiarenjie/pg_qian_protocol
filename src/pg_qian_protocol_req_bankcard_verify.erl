%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 十一月 2017 21:15
%%%-------------------------------------------------------------------
-module(pg_qian_protocol_req_bankcard_verify).
-compile({parse_trans, exprecs}).
-author("simon").
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-behaviour(pg_protocol).
-behaviour(pg_qian_protocol).

%% API
-mixin([
  {pg_qian_protocol, [pr_formatter/1, in_2_out_map/0]}
]).
-export([
  sign_fields/0
  , options/0
  , convert_config/0
]).

%%-------------------------------------------------------------------
-define(P, ?MODULE).

-record(?P, {
  token :: pg_qian_protocol:token()
  , ip :: pg_qian_protocol:ip()
  , mobile :: pg_qian_protocol:mobile()
  , id_no :: pg_qian_protocol:id_no()
  , id_name :: pg_qian_protocol:id_name()
  , bank_card_no :: pg_qian_protocol:bank_card_no()
%%  , txn_type = bankcard_verify

}).

-type ?P() :: #?P{}.
-export_type([?P/0]).
-export_records([?P]).


%%-------------------------------------------------------------------
sign_fields() ->
  [].

options() ->
  #{
    channel_type => qian,
    txn_type => bankcard_verify,
    direction=>req
  }.

%%-------------------------------------------------------------------
convert_config() ->
  [
    {default,
      [
        {to, ?MODULE},
        {from,
          [
            {pg_mcht_protocol_req_bankcard_verify,
              [
                {token, {fun token/1, [mobile]}}
                , {mobile, mobile}
                , {id_no, id_no}
                , {id_name, id_name}
                , {bank_card, bank_card_no}
              ]}
          ]
        }

      ]
    }
  ].


%%-------------------------------------------------------------------
token(Mobile)
  when (Mobile =:= undefined)
  orelse (Mobile =:= <<>>)
  ->
  %% verify 3 element
  pg_qian_protocol:get_config(token_3);
token(Mobile) ->
  pg_qian_protocol:get_config(token_4).

