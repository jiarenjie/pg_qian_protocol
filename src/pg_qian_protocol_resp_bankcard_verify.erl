%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 十一月 2017 21:16
%%%-------------------------------------------------------------------
-module(pg_qian_protocol_resp_bankcard_verify).
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
  ret_desc :: pg_qian_protocol:ret_desc()
  , ret_code :: pg_qian_protocol:ret_code()
  , is_certify_bankcard_three :: pg_qian_protocol:is_certify_bankcard()
  , is_certify_bankcard_four :: pg_qian_protocol:is_certify_bankcard()
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
    direction=>resp
  }.

%%-------------------------------------------------------------------
convert_config() ->
  [
    {default,
      [
        {to, proplists},
        {from,
          [
            {?MODULE,
              [
                {up_respCode,
                  {fun resp_code/3,
                    [ret_code, is_certify_bankcard_three, is_certify_bankcard_four]}}
                , {up_respMsg, ret_desc}
                , {txn_status,
                {fun txn_status/3,
                  [ret_code, is_certify_bankcard_three, is_certify_bankcard_four]}}
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
token(_Mobile) ->
  pg_qian_protocol:get_config(token_4).


%%-------------------------------------------------------------------
resp_code(1, 1, _) ->
  <<"00">>;
resp_code(1, _, 1) ->
  <<"00">>;
resp_code(0, _, _) ->
  <<"99">>.

%%-------------------------------------------------------------------
txn_status(1, 1, _) ->
  success;
txn_status(1, _, 1) ->
  success;
txn_status(0, _, _) ->
  fail.
