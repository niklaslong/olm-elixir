UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux) 
ERL_INCLUDE_PATH=$ERL_ROOT/usr/include/

all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-o olm_nifs.so olm_nifs.c -lolm
endif

ifeq ($(UNAME), Darwin) 
ERL_INCLUDE_PATH=$(ERL_ROOT)/include

all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-dynamiclib -undefined dynamic_lookup \
		-o olm_nifs.so olm_nifs.c -lolm
endif
