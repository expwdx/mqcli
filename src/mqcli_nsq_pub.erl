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

-spec(publish(Topic:: binary() | bitstring(), Msg:: term() | iodata() | binary()) -> ok).
publish(Topic, Msg) when is_binary(Msg) ->
  gen_server:cast(?MODULE, {publish, Topic, Msg}),
  ok;

publish(Topic, Msg) ->
  publish(Topic, jsx:encode(Msg)).


%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  DiscoveryServers = [{"localhost", 4161}],

  Channels = [
    {<<"test1">>, ensq_debug_callback},       %% Callback Module
    {<<"test2">>, ensq_debug_callback}
  ],

  Topics = [
    {<<"test">>, Channels, [{"localhost", 4150}]},
    {<<"topic1">>, Channels, [{"localhost", 4150}]},
    {<<"topic2">>, Channels, [{"localhost", 4150}]}
  ],

  ensq:init({DiscoveryServers, Topics}),

  %% Sending a message to a topic
  %%  ensq:send(test, <<"hello there!">>),
  {ok, #mqcli_nsq_pub_state{}}.

handle_call(_Request, _From, State = #mqcli_nsq_pub_state{}) ->
  {reply, ok, State}.

handle_cast({publish, Topic, Msg}, State = #mqcli_nsq_pub_state{}) ->
  %% Publish a message
%%  ensq:send(<<"topic1">>, <<"hello there!">>),
  ensq:send(topic1, Msg),
  ensq:send(Topic, Msg),
  {noreply, State};
handle_cast(_Request, State = #mqcli_nsq_pub_state{}) ->
%%  ensq:send(<<"topic1">>, <<"hello there!">>),
%%  ensq:send(<<"topic2">>, <<"hello there!">>),
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
