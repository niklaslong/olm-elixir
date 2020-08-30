#include "erl_nif.h"
#include <string.h>

#include <olm/inbound_group_session.h>
#include <olm/olm.h>
#include <olm/outbound_group_session.h>
#include <olm/pk.h>
#include <olm/sas.h>

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
account_last_error(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    // Perhaps make this atoms?
    const char* last_error = olm_account_last_error(account);

    return enif_make_string(env, last_error, ERL_NIF_LATIN1);
}

static ERL_NIF_TERM
create_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    size_t account_size = olm_account_size();

    // Allocate memory based on account_size.
    OlmAccount* memory  = enif_alloc_resource(account_resource, account_size);
    OlmAccount* account = olm_account(memory);

    size_t random_length = olm_create_account_random_length(account);
    char   bytes[random_length];

    size_t result = olm_create_account(account, bytes, random_length);

    // Return {:ok, account_ref} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        enif_release_resource(account);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_resource(env, account);
    enif_release_resource(account);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
pickle_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary key;
    ErlNifBinary pickled;

    OlmAccount* account;

    // Read args.
    enif_get_resource(env, argv[0], account_resource, (void**) &account);
    enif_inspect_binary(env, argv[1], &key);

    // Allocate buffer for result.
    size_t pickled_length = olm_pickle_account_length(account);
    enif_alloc_binary(pickled_length, &pickled);

    size_t result = olm_pickle_account(
        account, key.data, key.size, pickled.data, pickled_length);

    // Return {:ok, pickled} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        enif_release_binary(&pickled);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &pickled);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
unpickle_account(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary pickled, pickled_input;
    ErlNifBinary key;

    // Read args.
    enif_inspect_binary(env, argv[0], &pickled_input);
    enif_alloc_binary(pickled_input.size, &pickled);
    memcpy(pickled.data, pickled_input.data, pickled_input.size);

    enif_inspect_binary(env, argv[1], &key);

    // Initialise account memory.
    size_t      account_size = olm_account_size();
    OlmAccount* memory  = enif_alloc_resource(account_resource, account_size);
    OlmAccount* account = olm_account(memory);

    size_t result = olm_unpickle_account(
        account, key.data, key.size, pickled.data, pickled.size);

    // Return {:ok, account_ref} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        enif_release_resource(account);
        enif_release_binary(&pickled);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_resource(env, account);

    enif_release_resource(account);
    enif_release_binary(&pickled);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
account_identity_keys(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    // Allocate memory for identity keys.
    ErlNifBinary identity_keys;
    size_t       keys_length = olm_account_identity_keys_length(account);
    enif_alloc_binary(keys_length, &identity_keys);

    size_t result = olm_account_identity_keys(
        account, identity_keys.data, identity_keys.size);

    // Returns {:ok, identity_keys} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        enif_release_binary(&identity_keys);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &identity_keys);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
account_sign(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    ErlNifBinary message;
    enif_inspect_binary(env, argv[1], &message);

    ErlNifBinary signature;
    size_t       signature_length = olm_account_signature_length(account);
    enif_alloc_binary(signature_length, &signature);

    size_t result = olm_account_sign(
        account, message.data, message.size, signature.data, signature.size);

    // Returns {:ok, signed} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        enif_release_binary(&signature);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &signature);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
account_one_time_keys(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    ErlNifBinary one_time_keys;
    size_t one_time_keys_length = olm_account_one_time_keys_length(account);
    enif_alloc_binary(one_time_keys_length, &one_time_keys);

    size_t result = olm_account_one_time_keys(
        account, one_time_keys.data, one_time_keys.size);

    // Returns {:ok, one_time_keys} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        enif_release_binary(&one_time_keys);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &one_time_keys);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
account_mark_keys_as_published(ErlNifEnv*         env,
                               int                argc,
                               const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    size_t result = olm_account_mark_keys_as_published(account);

    // Returns {:ok, 'SUCCESS'} or {:error, last_error}.
    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term =
        enif_make_string(env, olm_account_last_error(account), ERL_NIF_LATIN1);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
account_max_one_time_keys(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    size_t max = olm_account_max_number_of_one_time_keys(account);

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_ulong(env, max);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
account_generate_one_time_keys(ErlNifEnv*         env,
                               int                argc,
                               const ERL_NIF_TERM argv[])
{
    // Get args.
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    size_t count;
    enif_get_ulong(env, argv[1], &count);

    size_t random_length =
        olm_account_generate_one_time_keys_random_length(account, count);

    // Needs more randomness?
    char   random[random_length];
    size_t result = olm_account_generate_one_time_keys(
        account, count, random, random_length);

    ERL_NIF_TERM result_atom;

    if (result == olm_error()) {
        result_atom = enif_make_atom(env, "error");
    } else {
        result_atom = enif_make_atom(env, "ok");
    }

    ERL_NIF_TERM error_message =
        enif_make_string(env, olm_account_last_error(account), ERL_NIF_LATIN1);

    return enif_make_tuple2(env, result_atom, error_message);
}

// Let's define the array of ErlNifFunc beforehand:
static ErlNifFunc nif_funcs[] = {
    // {erl_function_name, erl_function_arity, c_function}
    {"version", 0, version},
    {"account_last_error", 1, account_last_error},
    {"create_account", 0, create_account},
    {"pickle_account", 2, pickle_account},
    {"unpickle_account", 2, unpickle_account},
    {"account_identity_keys", 1, account_identity_keys},
    {"account_sign", 2, account_sign},
    {"account_one_time_keys", 1, account_one_time_keys},
    {"account_mark_keys_as_published", 1, account_mark_keys_as_published},
    {"account_max_one_time_keys", 1, account_max_one_time_keys},
    {"account_generate_one_time_keys", 2, account_generate_one_time_keys}};

ERL_NIF_INIT(Elixir.Olm.NIF, nif_funcs, nif_load, NULL, NULL, NULL)
