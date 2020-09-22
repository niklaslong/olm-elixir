ARCH := $(shell uname -s)
PREFIX ?= ./priv

ERL_INCLUDE_PATH=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

CFLAGS ?= -fPIC -shared -I$(ERL_INCLUDE_PATH)
LDFLAGS ?= -lolm

ifeq ($(ARCH), Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

all: $(PREFIX)/olm_nif.so

$(PREFIX)/olm_nif.so: c_src/olm_nif.c
	@mkdir -p "$(@D)"
	cc $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -rf $(PREFIX)
