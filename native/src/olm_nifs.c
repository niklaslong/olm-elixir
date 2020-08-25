#include "erl_nif.h"
#include <olm/inbound_group_session.h>
#include <olm/olm.h>
#include <olm/outbound_group_session.h>
#include <olm/pk.h>
#include <olm/sas.h>

static ErlNifResourceType* account_resource;
static ErlNifResourceType* session_resource;
static ErlNifResourceType* utility_resource;

// Not sure about the destructors yet.
void
account_dtor(ErlNifEnv* caller_env, void* account)
{
    olm_clear_account(account);
}

void
session_dtor(ErlNifEnv* caller_env, void* session)
{
    olm_clear_session(session);
}

void
utility_dtor(ErlNifEnv* caller_env, void* utility)
{
    olm_clear_utility(utility);
}

static int
nif_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    int flags        = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
    account_resource = enif_open_resource_type(
        env, NULL, "account", account_dtor, flags, NULL);

    session_resource = enif_open_resource_type(
        env, NULL, "session", session_dtor, flags, NULL);

    utility_resource = enif_open_resource_type(
        env, NULL, "utility", utility_dtor, flags, NULL);

    return 0;
}

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

    OlmAccount* memory  = enif_alloc_resource(account_resource, account_size);
    OlmAccount* account = olm_account(memory);

    ERL_NIF_TERM term = enif_make_resource(env, account);
    enif_release_resource(account);

    return term;
}

static ERL_NIF_TERM
init_session(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t session_size = argv[0];

    OlmSession* memory  = enif_alloc_resource(session_resource, session_size);
    OlmSession* session = olm_session(memory);

    return enif_make_resource(env, session);
}

static ERL_NIF_TERM
init_utility(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t utility_size = argv[0];

    OlmUtility* memory  = enif_alloc_resource(utility_resource, utility_size);
    OlmUtility* utility = olm_utility(memory);

    return enif_make_resource(env, utility);
}

static ERL_NIF_TERM
account_last_error(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    const char* last_error = olm_account_last_error(account);

    return enif_make_string(env, last_error, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM
pickle_account_length(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    size_t length = olm_pickle_account_length(account);

    return enif_make_ulong(env, length);
}

static ERL_NIF_TERM
pickle_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    size_t key_length;
    enif_get_ulong(env, argv[2], &key_length);

    char key[key_length];
    enif_get_string(env, argv[1], key, key_length, ERL_NIF_LATIN1);

    // Move this to args?
    size_t pickled_length = olm_pickle_account_length(account);

    char pickled[pickled_length];
    // We probably need some error handling here.
    size_t res =
        olm_pickle_account(account, key, key_length, pickled, pickled_length);

    return enif_make_string(env, pickled, ERL_NIF_LATIN1);
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
    {"init_utility", 1, init_utility},
    {"account_last_error", 1, account_last_error},
    {"pickle_account_length", 1, pickle_account_length},
    {"pickle_account", 3, pickle_account}};

ERL_NIF_INIT(Elixir.Olm, nif_funcs, nif_load, NULL, NULL, NULL)
