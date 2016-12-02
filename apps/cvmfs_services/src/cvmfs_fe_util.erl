%%%-------------------------------------------------------------------
%%% This file is part of the CernVM File System.
%%%
%%% @doc cvmfs_lease_handler
%%%
%%% @end
%%%-------------------------------------------------------------------

-module(cvmfs_fe_util).

-compile([{parse_transform, lager_transform}]).

-export([read_body/1, tick/2, tock/3]).

read_body(Req0) ->
    read_body_rec(Req0, <<"">>).

read_body_rec(Req0, Acc) ->
    case cowboy_req:read_body(Req0) of
        {ok, Data, Req1} ->
            DataSize = size(Data),
            {ok, <<Data:DataSize/binary,Acc/binary>>, Req1};
        {more, Data, Req1} ->
            DataSize = size(Data),
            read_body_rec(Req1, <<Data:DataSize/binary,Acc/binary>>)
    end.

tick(Req, Unit) ->
    T = erlang:monotonic_time(Unit),
    URI = cowboy_req:uri(Req),
    {URI, T}.

tock(URI, T0, Unit) ->
    T1 = erlang:monotonic_time(Unit),
    lager:info("HTTP request received: ~p ; time to process = ~p usec", [URI, T1 - T0]).