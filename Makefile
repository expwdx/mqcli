# common
.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

.yrl.erl:
	erlc -W $<

ERL = erl -boot start_clean

#rebar
REBAR3_URL=https://s3.amazonaws.com/rebar3/rebar3

ifeq ($(wildcard rebar3),rebar3)
REBAR3 = $(CURDIR)/rebar3
endif

REBAR3 ?= $(shell test -e `which rebar3` 2>/dev/null && which rebar3 || echo "./rebar3")

MODS = mqtt_client

.PHONY: deps test build

all: build test docs

build: $(REBAR3)
	@$(REBAR3) compile

$(REBAR3):
	wget $(REBAR3_URL) || curl -Lo rebar3 $(REBAR3_URL)
	@chmod a+x rebar3



deps:
	@$(REBAR3) get-deps

clean:
	@$(REBAR3) clean

distclean: clean
	@$(REBAR3) delete-deps

docs:
	@$(REBAR3) edoc

test:
	@$(REBAR3) do ct, cover

release: test
	@$(REBAR3) release

all:
	@$(REBAR3) compile
#	@erl -env ERL_LIBS '_build/default/lib/amqp_client' '_build/default/lib/rabbit_common' '_build/default/lib/amqp_client/ebin' -pa '_build/default/lib/mqcli/ebin' -eval "mqcli:start('hello', 'world')"
	@erl -env ERL_LIBS _build/default/lib -eval 'application:ensure_all_started(mqcli).' -noshell
