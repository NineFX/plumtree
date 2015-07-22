-module(plumtree_metadata_cleanup_sup).

-behaviour(supervisor).

%% API functions
-export([start_link/0,
         get_pid/1,
         get_full_prefix_and_pid/0,
         add_full_prefix/1]).

%% Supervisor callbacks
-export([init/1]).

-define(CHILD(Id, Mod, Type, Args), {Id, {Mod, start_link, Args},
                                     permanent, 5000, Type, [Mod]}).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

add_full_prefix(FullPrefix) ->
    supervisor:start_child(?MODULE,
                           ?CHILD({plumtree_metadata_cleanup, FullPrefix},
                                  plumtree_metadata_cleanup, worker, [FullPrefix])).

get_pid(FullPrefix) ->
    case lists:keyfind({plumtree_metadata_cleanup, FullPrefix}, 1,
                       supervisor:which_children(?MODULE)) of
        {_, Pid, _, _} when is_pid(Pid) ->
            {ok, Pid};
        _ ->
            {error, not_found}
    end.

get_full_prefix_and_pid() ->
    [{FullPrefix, Pid} || {{plumtree_metadata_cleanup, FullPrefix}, Pid, _, _}
                          <- supervisor:which_children(?MODULE), is_pid(Pid)].


%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    {ok, {{one_for_one, 5, 10}, []}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================