-module(mod_http_presence).

-behaviour(gen_mod).

-include("ejabberd.hrl").
%% Required by ?INFO_MSG macros
%%-include("logger.hrl").

%% gen_mod API callbacks
-export([start/2, stop/1, on_set/4, on_unset/4]).

start(_Host, _Opts) ->
%% Needed for httpc:request
    ok = case inets:start() of
        {error, {already_started, inets}} ->
            ok;
        ok ->
            ok
        end,

%%    ?INFO_MSG("Hello, ejabberd world!", []),
    ejabberd_hooks:add(set_presence_hook, _Host, ?MODULE, on_set, 50),
    ejabberd_hooks:add(unset_presence_hook, _Host, ?MODULE, on_unset, 50),
    ok.

stop(_Host) ->
%%    ?INFO_MSG("Bye bye, ejabberd world!", []),
    ejabberd_hooks:delete(set_presence_hook, _Host, ?MODULE, on_set, 50),
    ejabberd_hooks:delete(unset_presence_hook, _Host, ?MODULE, on_unset, 50),
    ok.

on_set(User, Server, _Resource, _Packet) ->
%%    ?INFO_MSG("~p - ~p - changed status", [User, Server]),
    http_request("status_change", User, Server),
    ok.

on_unset(User, Server, _Resource, _Packet) ->
%%    ?INFO_MSG("~p - ~p - logged out", [User, Server]),
    http_request("logout", User, Server),
    ok.

http_request(Action, User, Server) ->
    Request = "action=" ++ Action ++ "&user=" ++ binary_to_list(User) ++ "@" ++ binary_to_list(Server),
    Url = get_opt(url),
    httpc:request(post, {Url, [], "application/x-www-form-urlencoded", Request}, [], []),
    ok.

get_opt(Opt) ->
    get_opt(Opt, undefined).

get_opt(Opt, Default) ->
    F = fun(Val) when is_binary(Val) -> binary_to_list(Val);
           (Val)                     -> Val
        end,
    gen_mod:get_module_opt(global, ?MODULE, Opt, F, Default).
