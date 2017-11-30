%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 十一月 2017 18:46
%%%-------------------------------------------------------------------
-module(pg_qian_protocol_config).
-author("simon").
-include_lib("eunit/include/eunit.hrl").

-behaviour(gen_server).

%% API
-export([
  start_link/0
  , get_config/1
]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([
  get_init_state_test_1/0
]).

-define(SERVER, ?MODULE).
-define(APP, pg_qian_protocol).

-record(state, {token_3, token_4, url}).

%%%===================================================================
%%% API
%%%===================================================================
get_config(Key) when is_atom(Key) ->
  true = lists:member(Key, record_info(fields, state)),
  gen_server:call(?SERVER, {get, Key}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {Token3, Token4, Url} = get_init_state(),
  lager:info("App init state: token_3 = ~p,token_4=~p,url=~p", [Token3, Token4, Url]),
  {ok, #state{token_3 = Token3, token_4 = Token4, url = Url}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call({get, token_3}, _From, #state{token_3 = Value} = State) ->
  {reply, Value, State};
handle_call({get, token_4}, _From, #state{token_4 = Value} = State) ->
  {reply, Value, State};
handle_call({get, url}, _From, #state{url = Value} = State) ->
  {reply, Value, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_config_file_prop() ->
  {ok, Config} = application:get_env(?APP, config_file),
  Config.

get_init_state() ->
  ConfigFileName = xfutils:get_filename(?APP, get_config_file_prop()),
  lager:debug("ConfigFileName = ~ts", [ConfigFileName]),
  ?debugFmt("ConfigFileName = ~ts", [ConfigFileName]),
  {ok, [ConfigMap]} = file:consult(ConfigFileName),
  #{token_3:= Token3, token_4:=Token4, url:=Url} = ConfigMap,
  {Token3, Token4, Url}.

get_init_state_test_1() ->
  ?assertEqual({<<"token_3 example">>, <<"token_4 example">>, <<"url example">>},
    get_init_state()),
  ok.