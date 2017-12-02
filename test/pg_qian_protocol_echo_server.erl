%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 十一月 2017 22:32
%%%-------------------------------------------------------------------
-module(pg_qian_protocol_echo_server).
-author("simon").

%% API
-export([echo/3]).

echo(SessionID, _Env, Input) ->
  lager:error("================================~p", [Input]),
  Header = ["Content-Type: text/plain; charset=utf-8\r\n\r\n"],
%%  Content = "echo返回：",
  Out = <<"{\"ret_desc\":\"成功\",\"rsp_body\":{\"pid\":{\"pid\":\"511002198xxxxxxxxx\"},\"name\":{\"name\":\"xxx\"},\"bank_card\":{\"bank_card\":\"511002198xxxxxxxxx\"},\"summary\":{\"is_certify_bankcard_three\":1}},\"ret_code\":1}"/utf8>>,
  mod_esi:deliver(SessionID, [Header, Out]).
