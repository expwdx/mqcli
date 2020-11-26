%%%-------------------------------------------------------------------
%%% @author wangdongxing
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(mqcli_nsq_pub).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(mqcli_nsq_pub_state, {}).

-spec(publish(Exchange:: binary() | bitstring(), RoutingKey:: binary(), Msg:: term() | iodata() | binary()) -> ok).
publish(Exchange, RoutingKey, Msg) when is_binary(Msg) ->
  gen_server:cast(?MODULE, {publish, Exchange, RoutingKey, Msg}),
  ok;

publish(Exchange, RoutingKey, Msg) ->
  publish(Exchange, RoutingKey, jsx:encode(Msg)).


%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  DiscoveryServers = [{"localhost", 4161}],
  Channels = [
    {<<"test">>,                  %% Channel name
    ensq_debug_callback},       %% Callback Module
    {<<"test2">>, ensq_debug_callback}],
  ensq_topic:discover(
    test,                                   %% Topic
    DiscoveryServers,                       %% Discovery servers to use
    Channels,                               %% Channels to join.
    [{"localhost", 4150}]),                 %% Targets for SUBing

  ensq:init(DiscoveryServers, ),

  %% Sending a message to a topic
  ensq:send(test, <<"hello there!">>),
  {ok, #mqcli_nsq_pub_state{}}.

handle_call(_Request, _From, State = #mqcli_nsq_pub_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #mqcli_nsq_pub_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #mqcli_nsq_pub_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #mqcli_nsq_pub_state{}) ->
  ok.

code_change(_OldVsn, State = #mqcli_nsq_pub_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
