%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 十一月 2017 18:45
%%%-------------------------------------------------------------------
-module(pg_qian_protocol).
-author("simon").
-include_lib("eunit/include/eunit.hrl").
-include_lib("mixer/include/mixer.hrl").
-include("include/type_qian_protocol.hrl").

%% callbacks
-callback sign_fields() -> [atom()].
-callback options() -> map().

%% API
-mixin([
  {pg_qian_protocol_config, [get_config/1]}

]).

%% callback of pg_protocol
-export([in_2_out_map/0]).

%% callback of pg_model:pr
-export([pr_formatter/1]).

-export([out_2_in_fix/1]).


%%=========================================================
%% API functions
%%=========================================================
pr_formatter(Field)
  when (Field =:= id_name)
  orelse (Field =:= ret_desc)
  ->
  string;
pr_formatter(_) ->
  default.

%%----------------------------------------------------------
in_2_out_map() ->
  #{
    token=> <<"token">>
    , ip => <<"ip">>
    , mobile => <<"mobile">>
    , id_no => <<"pid">>
    , id_name => <<"name">>
    , bank_card_no => <<"bank_card">>
    , ret_desc => <<"ret_desc">>
    , ret_code => <<"ret_code">>
    , is_certify_bankcard_four => <<"rsp_body_summary_is_certify_bankcard_four">>
    , is_certify_bankcard_three => <<"rsp_body_summary_is_certify_bankcard_three">>
  }.
%%----------------------------------------------------------
%% convert json resp body to PV proplists
%%------------------------------------------------------------
out_2_in_fix(JsonBody) when is_binary(JsonBody) ->
  Json = jsx:decode(JsonBody),
  FlattenJsonPV = flatten_json(Json),
  FlattenJsonPV.

%%------------------------------------------------------------
flatten_json(Json) ->
  ?debugFmt("Json = ~p", [Json]),
  do_flatten_json(Json, []).

do_flatten_json([], Acc) ->
  lists:flatten(lists:reverse(Acc));
do_flatten_json([{Key, Value} | Tail], Acc) when is_binary(Key), (not is_list(Value)) ->
  do_flatten_json(Tail, [{Key, Value} | Acc]);
do_flatten_json([{Key, List} | Tail], Acc) when is_binary(Key), is_list(List) ->
  do_flatten_json(Tail, [do_deep_flatten_json(Key, List) | Acc]).

%%------------------------------------------------------------
flatten_json_test() ->
  Json = [{<<"ret_desc">>, <<230, 136, 144, 229, 138, 159>>},
    {<<"rsp_body">>,
      [{<<"pid">>, [{<<"pid">>, <<"511002198xxxxxxxxx">>}]},
        {<<"name">>, [{<<"name">>, <<"xxx">>}]},
        {<<"bank_card">>, [{<<"bank_card">>, <<"511002198xxxxxxxxx">>}]},
        {<<"summary">>, [{<<"is_certify_bankcard_three">>, 1}]}]},
    {<<"ret_code">>, 1}],
  ?assertEqual(
    [
      {<<"ret_desc">>, <<"成功"/utf8>>}
      , {<<"rsp_body_pid_pid">>, <<"511002198xxxxxxxxx">>}
      , {<<"rsp_body_name_name">>, <<"xxx">>}
      , {<<"rsp_body_bank_card_bank_card">>, <<"511002198xxxxxxxxx">>}
      , {<<"rsp_body_summary_is_certify_bankcard_three">>, 1}
      , {<<"ret_code">>, 1}
    ],
    flatten_json(Json)
  ),
  ok.
%%------------------------------------------------------------
do_deep_flatten_json(Key, List) ->
  do_deep_flatten_json(Key, List, []).

key_join(Key, Key1) when is_binary(Key), is_binary(Key1) ->
  <<Key/binary, "_", Key1/binary>>.

do_deep_flatten_json(_Key, [], Acc) ->
  lists:flatten(lists:reverse(Acc));
do_deep_flatten_json(Key, [{Key1, Value}], Acc)
  when is_binary(Key), is_binary(Key1), (not is_list(Value)) ->
  do_deep_flatten_json(Key, [],
    [{key_join(Key, Key1), Value} | Acc]);
do_deep_flatten_json(Key, [{Key1, Value} | Tail], Acc)
  when is_binary(Key), is_binary(Key1), (not is_list(Value)) ->
  do_deep_flatten_json(Key, Tail,
    [do_deep_flatten_json(Key, [{Key1, Value}]) | Acc]);
do_deep_flatten_json(Key, [{Key1, List} | Tail], Acc)
  when is_binary(Key), is_binary(Key1), is_list(List), is_list(Acc) ->
  do_deep_flatten_json(Key, Tail,
    [do_deep_flatten_json(key_join(Key, Key1), List, Acc)]).

%%------------------------------------------------------------
do_deep_flatten_json_test() ->
  ?assertEqual([{<<"resp_body_pid">>, <<"aaa">>}]
    , do_deep_flatten_json(<<"resp_body">>, [{<<"pid">>, <<"aaa">>}])),
  ?assertEqual([{<<"resp_body_pid">>, <<"aaa">>}, {<<"resp_body_pid1">>, <<"bbb">>}]
    , do_deep_flatten_json(<<"resp_body">>, [{<<"pid">>, <<"aaa">>}, {<<"pid1">>, <<"bbb">>}])),
  ok.


