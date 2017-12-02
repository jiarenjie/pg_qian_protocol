%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 十一月 2017 20:24
%%%-------------------------------------------------------------------
-module(pg_qian_protocol_SUITE).
-author("simon").
-include_lib("eunit/include/eunit.hrl").

%% API
-export([]).

-define(APP, pg_qian_protocol).

%%-------------------------------------------------------------------
cleanup(_Pid) ->
  db_init(),
  ok.

setup() ->
  pg_test_utils:lager_init(),
  pg_test_utils:setup(mnesia),

  application:start(pg_qian_protocol),

  pg_test_utils:http_echo_server_init(pg_qian_protocol_echo_server),

  env_init(),

  db_init(),

  ok.


db_init() ->
  RepoContents = [
  ],

  pg_test_utils:db_init(RepoContents),
  ok.
%%---------------------------------------------------------------
env_init() ->
  Cfgs = [
    {?APP,
      [
        {priv_dir, "/priv"}
        , {qian_token_dir, "/keys"}
        , {config_filename, "qian.config"}
        , {config_file, [priv, qian_token_dir, config_filename]}
      ]
    }
  ],

  pg_test_utils:env_init(Cfgs),
  ok.
%%---------------------------------------------------------------
my_test_() ->
  {
    setup
    , fun setup/0
    , fun cleanup/1
    ,
    {
      inorder,
      [
        fun pg_qian_protocol_config:get_init_state_test_1/0
        , fun get_test_1/0
        , fun echo_server_test_1/0
        , fun resp_bankcard_verify_test_1/0
      ]
    }

  }.
%%---------------------------------------------------------------
get_test_1() ->
  ?assertEqual(<<"token_3 example">>, pg_qian_protocol:get_config(token_3)),
  ok.
%%---------------------------------------------------------------
echo_server_test_1() ->
  {StatusCode, _Header, Body} = xfutils:fetch("http://localhost:9999/esi/pg_qian_protocol_echo_server:echo", [{a, b}, {c, d}]),
  ?assertEqual(200, StatusCode),
  ?assertEqual(<<"{\"ret_desc\":\"成功\",\"rsp_body\":{\"pid\":{\"pid\":\"511002198xxxxxxxxx\"},\"name\":{\"name\":\"xxx\"},\"bank_card\":{\"bank_card\":\"511002198xxxxxxxxx\"},\"summary\":{\"is_certify_bankcard_three\":1}},\"ret_code\":1}"/utf8>>
    , Body),
  Json = jsx:decode(Body),
  ?debugFmt("Json = ~p", [Json]),
  ok.
%%--------------------------------------------------------------------
resp_bankcard_verify_test_1() ->
  MProtocol = pg_qian_protocol_resp_bankcard_verify,
  {StatusCode, _Header, Body} = xfutils:fetch("http://localhost:9999/esi/pg_qian_protocol_echo_server:echo", []),
  ?assertEqual(200, StatusCode),
  PV = pg_qian_protocol:out_2_in_fix(Body),
  P = pg_protocol:out_2_in(MProtocol, PV),
  lager:debug("Resp bankcard verify = ~ts", [pg_model:pr(MProtocol, P)]),
  ?assertEqual([<<"成功"/utf8>>, 1, undefined, 1],
    pg_model:get(MProtocol, P, [ret_desc, is_certify_bankcard_three, is_certify_bankcard_four, ret_code])),
  ok.


