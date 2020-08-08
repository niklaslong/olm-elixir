ERL_INCLUDE_PATH=$ERL_ROOT/usr/include/
UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux) 
all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-o olm_nifs.so olm_nifs.c -lolm -lstdc++
endif

ifeq ($(UNAME), Darwin) 
all::
	cc -fPIC -shared -I$(ERL_INCLUDE_PATH) \
		-dynamiclib -undefined dynamic_lookup \
		-o olm_nifs.so olm_nifs.c -lolm -lstdc++
endif
