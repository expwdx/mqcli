# common
.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

.yrl.erl:
	erlc -W $<

ERL = erl -boot start_clean

MODS = mqtt_client

all:
	rebar3 compile
#	@erl -env ERL_LIBS '_build/default/lib/amqp_client' '_build/default/lib/rabbit_common' '_build/default/lib/amqp_client/ebin' -pa '_build/default/lib/mqcli/ebin' -eval "mqcli:start('hello', 'world')"
	@erl -env ERL_LIBS _build/default/lib -eval 'application:ensure_all_started(mqcli).' -noshell
clean:
	rm -rf _build
