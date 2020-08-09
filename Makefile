UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux) 
ERL_INCLUDE_PATH=$ERL_ROOT/usr/include/

# Creates directory for object files.
$(shell mkdir priv/native) 

all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-o priv/native/olm_nifs.so native/src/olm_nifs.c -lolm
endif

ifeq ($(UNAME), Darwin) 
ERL_INCLUDE_PATH=$(ERL_ROOT)/include

# Creates directory for object files.
$(shell mkdir priv/native)

all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-dynamiclib -undefined dynamic_lookup \
		-o priv/native/olm_nifs.so native/src/olm_nifs.c -lolm
endif
