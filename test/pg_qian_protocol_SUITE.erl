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
  application:start(pg_qian_protocol),
  env_init(),

  pg_test_utils:setup(mnesia),

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

      ]
    }

  }.
%%---------------------------------------------------------------
get_test_1() ->
  ?assertEqual(<<"token_3 example">>, pg_qian_protocol:get_config(token_3)),
  ok.
