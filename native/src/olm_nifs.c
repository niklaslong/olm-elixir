#include "erl_nif.h"
#include <olm/inbound_group_session.h>
#include <olm/olm.h>
#include <olm/outbound_group_session.h>
#include <olm/pk.h>
#include <olm/sas.h>
#include <stdio.h>

static ErlNifResourceType* account_resource;

void
account_dtor(ErlNifEnv* caller_env, void* account)
{
    olm_clear_account(account);
}

static int
nif_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    int flags        = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
    account_resource = enif_open_resource_type(
        env, NULL, "account", account_dtor, flags, NULL);

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
account_last_error(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    const char* last_error = olm_account_last_error(account);

    return enif_make_string(env, last_error, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM
create_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t account_size = olm_account_size();

    OlmAccount* memory  = enif_alloc_resource(account_resource, account_size);
    OlmAccount* account = olm_account(memory);

    size_t random_length = olm_create_account_random_length(account);

    // TODO: needs more randomness?
    char bytes[random_length];
    olm_create_account(account, bytes, random_length);

    ERL_NIF_TERM term = enif_make_resource(env, account);
    enif_release_resource(account);

    return term;
}

static ERL_NIF_TERM
pickle_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    // size_t key_length;
    // enif_get_ulong(env, argv[2], &key_length);

    // char key[key_length];
    // enif_get_string(env, argv[1], key, key_length, ERL_NIF_LATIN1);

    char   key[]      = "key";
    size_t key_length = sizeof(key);

    size_t pickled_length = olm_pickle_account_length(account);
    // char   pickled[pickled_length];

    ErlNifBinary pickled;
    enif_alloc_binary(pickled_length, &pickled);

    // Error handling needs to be added.
    size_t res = olm_pickle_account(
        account, key, key_length, pickled.data, pickled_length);

    // printf("%s", pickled);

    return enif_make_binary(env, &pickled);

    // return enif_make_string(env, pickled, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM
unpickle_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    // size_t pickled_length;
    // enif_get_ulong(env, argv[1], &pickled_length);

    // char pickled_account[pickled_length];
    // enif_get_string(env, argv[0], pickled_account, pickled_length,
    // ERL_NIF_LATIN1);

    // printf("%s", pickled_account);

    ErlNifBinary pickled_account;
    enif_inspect_binary(env, argv[0], &pickled_account);

    // size_t key_length;
    // enif_get_ulong(env, argv[3], &key_length);

    // char key[key_length];
    // enif_get_string(env, argv[2], key, key_length, ERL_NIF_LATIN1);

    char   key[]      = "key";
    size_t key_length = sizeof(key);

    size_t      account_size = olm_account_size();
    OlmAccount* memory  = enif_alloc_resource(account_resource, account_size);
    OlmAccount* account = olm_account(memory);

    olm_unpickle_account(account, key, key_length, pickled_account.data, 246);

    ERL_NIF_TERM term = enif_make_resource(env, account);
    enif_release_resource(account);

    // return enif_make_string(env, last_error, ERL_NIF_LATIN1);
    return term;
}

static ERL_NIF_TERM
account_idenitiy_keys(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    size_t keys_length = olm_account_identity_keys_length(account);

    char identity_keys[keys_length];
    olm_account_identity_keys(account, identity_keys, keys_length);

    return enif_make_string(env, identity_keys, ERL_NIF_LATIN1);
}

// Let's define the array of ErlNifFunc beforehand:
static ErlNifFunc nif_funcs[] = {
    // {erl_function_name, erl_function_arity, c_function}
    {"version", 0, version},
    {"account_last_error", 1, account_last_error},
    {"session_size", 0, session_size},
    {"utility_size", 0, utility_size},
    {"create_account", 0, create_account},
    {"pickle_account", 3, pickle_account},
    {"unpickle_account", 4, unpickle_account},
    {"account_identity_keys", 1, account_idenitiy_keys}};

ERL_NIF_INIT(Elixir.Olm, nif_funcs, nif_load, NULL, NULL, NULL)
