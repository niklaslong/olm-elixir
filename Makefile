UNAME := $(shell uname -s)

# Creates directory for object files.
$(shell mkdir priv)

ifeq ($(UNAME), Linux) 
ERL_INCLUDE_PATH=$ERL_ROOT/usr/include/

all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-o priv/olm_nif.so c_src/olm_nif.c -lolm
endif

ifeq ($(UNAME), Darwin) 
ERL_INCLUDE_PATH=$(ERL_ROOT)/include

all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-dynamiclib -undefined dynamic_lookup \
		-o priv/olm_nif.so c_src/olm_nif.c -lolm
endif
