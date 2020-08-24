#include "erl_nif.h"
#include <olm/inbound_group_session.h>
#include <olm/olm.h>
#include <olm/outbound_group_session.h>
#include <olm/pk.h>
#include <olm/sas.h>

static ERL_NIF_TERM
version(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    uint8_t major, minor, patch;
    olm_get_library_version(&major, &minor, &patch);

    return enif_make_tuple3(env,
                            enif_make_uint(env, major),
                            enif_make_uint(env, minor),
                            enif_make_uint(env, patch));
}

static ERL_NIF_TERM
account_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t size = olm_account_size();

    return enif_make_ulong(env, size);
}

static ERL_NIF_TERM
session_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t size = olm_session_size();

    return enif_make_ulong(env, size);
}

static ERL_NIF_TERM
utility_size(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t size = olm_utility_size();

    return enif_make_ulong(env, size);
}

static ERL_NIF_TERM
init_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t account_size = argv[0];

    // BEAM specific impl of malloc, won't be GC and needs to be freed.
    OlmAccount* memory  = enif_alloc(account_size);
    OlmAccount* account = olm_account(memory);

    return enif_make_resource(env, &account);
}

static ERL_NIF_TERM
init_session(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t session_size = argv[0];

    OlmSession* memory  = enif_alloc(session_size);
    OlmSession* session = olm_session(memory);

    return enif_make_resource(env, &session);
}

static ERL_NIF_TERM
init_utility(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t utility_size = argv[0];

    OlmUtility* memory  = enif_alloc(utility_size);
    OlmUtility* utility = olm_utility(memory);

    return enif_make_resource(env, &utility);
}

// Let's define the array of ErlNifFunc beforehand:
static ErlNifFunc nif_funcs[] = {
    // {erl_function_name, erl_function_arity, c_function}
    {"version", 0, version},
    {"account_size", 0, account_size},
    {"session_size", 0, session_size},
    {"utility_size", 0, utility_size},
    {"init_account", 1, init_account},
    {"init_session", 1, init_session},
    {"init_utility", 1, init_utility}};

ERL_NIF_INIT(Elixir.Olm, nif_funcs, NULL, NULL, NULL, NULL)
