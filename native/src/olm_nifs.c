#include "erl_nif.h"
#include <olm/olm.h>
#include <olm/outbound_group_session.h>
#include <olm/inbound_group_session.h>
#include <olm/pk.h>
#include <olm/sas.h>


static ERL_NIF_TERM
version(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    uint8_t major, minor, patch;
    olm_get_library_version(&major, &minor, &patch);

    return enif_make_tuple3(env,
			    enif_make_int(env, major),
			    enif_make_int(env, minor),
			    enif_make_int(env, patch));
}

// Let's define the array of ErlNifFunc beforehand:
static ErlNifFunc nif_funcs[] = {
				 // {erl_function_name, erl_function_arity, c_function}
				 {"version", 0, version}
};

ERL_NIF_INIT(Elixir.Olm, nif_funcs, NULL, NULL, NULL, NULL)
