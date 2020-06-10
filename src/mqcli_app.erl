%%%-------------------------------------------------------------------
%%% @author marco
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Jun 2020 10:38 PM
%%%-------------------------------------------------------------------
-module(mqcli_app).
-author("marco").

-behaviour(application).

-include_lib("amqp_client/include/amqp_client.hrl").
-include("mqcli.hrl").

%% Application callbacks
-export([start/2,
  stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application is started using
%% application:start/[1,2], and should start the processes of the
%% application. If the application is structured according to the OTP
%% design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
  {ok, pid()} |
  {ok, pid(), State :: term()} |
  {error, Reason :: term()}).
start(_StartType, _StartArgs) ->
  Sup = case mqcli_sup:start_link() of
    {ok, Pid} -> Pid;
    {error, {already_started, Pid}} -> Pid
  end,
  io:format("application start, PID: ~p~n", [Sup]),
%%  application:get_env(lager),
%%  lager:start(),
%%  lager:error("Some message"),
  start_child(Sup, mqcli),
  start_child(Sup, mqcli_hook),
  publish_msg(),
  {ok, Sup}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application has stopped. It
%% is intended to be the opposite of Module:start/2 and should do
%% any necessary cleaning up. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(stop(State :: term()) -> term()).
stop(_State) ->
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================

start_child(Sup, Module) ->
  io:fwrite("start child: ~p~n", [Module]),
  {ok, Cpid} = supervisor:start_child(Sup, worker_spec(Module)),
  io:fwrite("child: ~p started ~n", [Cpid]).

worker_spec(Module) ->
  worker_spec(Module, start_link, []).
worker_spec(M, F, A) ->
  {M, {M, F, A}, permanent, 10000, worker, [M]}.

publish_msg() ->
  mqcli_hook:on_message_publish(#message{from = testpush, topic = <<"/test">>, payload = #{<<"hello">> => <<"world">>}}, <<"_">>),
  io:format("send msg~n~n~n"),
  timer:sleep(2000),
  publish_msg().

test1() ->
  {ok, Connection} =
    amqp_connection:start(#amqp_params_network{}),
  {ok, Channel} = amqp_connection:open_channel(Connection),
  ok = amqp_channel:close(Channel),
  ok = amqp_connection:close(Connection),
  ok.

