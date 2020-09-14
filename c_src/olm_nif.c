#include "erl_nif.h"
#include <string.h>

#include <olm/inbound_group_session.h>
#include <olm/olm.h>
#include <olm/outbound_group_session.h>
#include <olm/pk.h>
#include <olm/sas.h>

// Resource setup

static ErlNifResourceType* account_resource;
static ErlNifResourceType* session_resource;

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

static int
nif_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

    account_resource = enif_open_resource_type(
        env, NULL, "account", account_dtor, flags, NULL);

    session_resource = enif_open_resource_type(
        env, NULL, "session", session_dtor, flags, NULL);

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

// Accounts

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
    ERL_NIF_TERM msg     = enif_make_string(
        env, "Successfully marked keys as published", ERL_NIF_LATIN1);

    return enif_make_tuple2(env, ok_atom, msg);
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
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_account_last_error(account), ERL_NIF_LATIN1);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    result_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM msg =
        enif_make_string(env, "Successfully generated", ERL_NIF_LATIN1);

    return enif_make_tuple2(env, result_atom, msg);
}

// Sessions

static ERL_NIF_TERM
create_outbound_session(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    ErlNifBinary peer_id_key;
    enif_inspect_binary(env, argv[1], &peer_id_key);

    ErlNifBinary peer_one_time_key;
    enif_inspect_binary(env, argv[2], &peer_one_time_key);

    // Allocate new session
    size_t      session_size = olm_session_size();
    OlmSession* memory  = enif_alloc_resource(session_resource, session_size);
    OlmSession* session = olm_session(memory);

    size_t random_length = olm_create_outbound_session_random_length(session);
    char   bytes[random_length];

    size_t result = olm_create_outbound_session(session,
                                                account,
                                                peer_id_key.data,
                                                peer_id_key.size,
                                                peer_one_time_key.data,
                                                peer_one_time_key.size,
                                                bytes,
                                                random_length);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_session_last_error(session), ERL_NIF_LATIN1);

        enif_release_resource(session);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_resource(env, session);
    enif_release_resource(session);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
create_inbound_session_from(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmAccount* account;
    enif_get_resource(env, argv[0], account_resource, (void**) &account);

    ErlNifBinary cyphertext, cyphertext_input;
    enif_inspect_binary(env, argv[1], &cyphertext_input);
    enif_alloc_binary(cyphertext_input.size, &cyphertext);
    memcpy(cyphertext.data, cyphertext_input.data, cyphertext_input.size);

    ErlNifBinary peer_id_key;
    enif_inspect_binary(env, argv[2], &peer_id_key);

    // Allocate new session
    size_t      session_size = olm_session_size();
    OlmSession* memory  = enif_alloc_resource(session_resource, session_size);
    OlmSession* session = olm_session(memory);

    size_t result = olm_create_inbound_session_from(session,
                                                    account,
                                                    peer_id_key.data,
                                                    peer_id_key.size,
                                                    cyphertext.data,
                                                    cyphertext.size);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_session_last_error(session), ERL_NIF_LATIN1);

        enif_release_resource(session);
        enif_release_binary(&cyphertext);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_resource(env, session);

    enif_release_resource(session);
    enif_release_binary(&cyphertext);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
encrypt_message_type(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmSession* session;
    enif_get_resource(env, argv[0], session_resource, (void**) &session);

    size_t result = olm_encrypt_message_type(session);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_session_last_error(session), ERL_NIF_LATIN1);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM type    = enif_make_ulong(env, result);

    return enif_make_tuple2(env, ok_atom, type);
}

static ERL_NIF_TERM
encrypt_message(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmSession* session;
    enif_get_resource(env, argv[0], session_resource, (void**) &session);

    ErlNifBinary plaintext;
    enif_inspect_binary(env, argv[1], &plaintext);

    size_t random_length = olm_encrypt_random_length(session);
    char   bytes[random_length];

    ErlNifBinary message;
    size_t message_length = olm_encrypt_message_length(session, plaintext.size);
    enif_alloc_binary(message_length, &message);

    size_t result = olm_encrypt(session,
                                plaintext.data,
                                plaintext.size,
                                bytes,
                                random_length,
                                message.data,
                                message.size);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_session_last_error(session), ERL_NIF_LATIN1);

        enif_release_binary(&message);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &message);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
decrypt_message(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    OlmSession* session;
    enif_get_resource(env, argv[0], session_resource, (void**) &session);

    size_t type;
    enif_get_ulong(env, argv[1], &type);

    ErlNifBinary cyphertext, cyphertext_input;
    enif_inspect_binary(env, argv[2], &cyphertext_input);
    enif_alloc_binary(cyphertext_input.size, &cyphertext);
    memcpy(cyphertext.data, cyphertext_input.data, cyphertext_input.size);

    ErlNifBinary plaintext;
    size_t       plaintext_size = olm_decrypt_max_plaintext_length(
        session, type, cyphertext_input.data, cyphertext_input.size);

    enif_alloc_binary(plaintext_size, &plaintext);

    size_t result = olm_decrypt(session,
                                type,
                                cyphertext.data,
                                cyphertext.size,
                                plaintext.data,
                                plaintext.size);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_session_last_error(session), ERL_NIF_LATIN1);

        enif_release_binary(&plaintext);
        enif_release_binary(&cyphertext);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &plaintext);

    enif_release_binary(&cyphertext);

    return enif_make_tuple2(env, ok_atom, term);
}

// Utility

static ERL_NIF_TERM
utility_sha256(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    // Args
    ErlNifBinary input;
    enif_inspect_binary(env, argv[0], &input);

    size_t      utility_size = olm_utility_size();
    OlmUtility* memory       = enif_alloc(utility_size);
    OlmUtility* utility      = olm_utility(memory);

    ErlNifBinary output;
    size_t       output_length = olm_sha256_length(utility);
    enif_alloc_binary(output_length, &output);

    size_t result =
        olm_sha256(utility, input.data, input.size, output.data, output.size);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_utility_last_error(utility), ERL_NIF_LATIN1);

        enif_release_binary(&output);
        enif_free(memory);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM term    = enif_make_binary(env, &output);

    enif_free(memory);

    return enif_make_tuple2(env, ok_atom, term);
}

static ERL_NIF_TERM
utility_ed25519_verify(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary key;
    ErlNifBinary message;
    ErlNifBinary signature, signature_input;

    enif_inspect_binary(env, argv[0], &key);
    enif_inspect_binary(env, argv[1], &message);

    enif_inspect_binary(env, argv[2], &signature_input);
    enif_alloc_binary(signature_input.size, &signature);
    memcpy(signature.data, signature_input.data, signature_input.size);

    size_t      utility_size = olm_utility_size();
    OlmUtility* memory       = enif_alloc(utility_size);
    OlmUtility* utility      = olm_utility(memory);

    size_t result = olm_ed25519_verify(utility,
                                       key.data,
                                       key.size,
                                       message.data,
                                       message.size,
                                       signature.data,
                                       signature.size);

    if (result == olm_error()) {
        ERL_NIF_TERM error_atom    = enif_make_atom(env, "error");
        ERL_NIF_TERM error_message = enif_make_string(
            env, olm_utility_last_error(utility), ERL_NIF_LATIN1);

        enif_free(memory);
        enif_release_binary(&signature);

        return enif_make_tuple2(env, error_atom, error_message);
    }

    ERL_NIF_TERM ok_atom = enif_make_atom(env, "ok");
    ERL_NIF_TERM msg =
        enif_make_string(env, "Signature verified", ERL_NIF_LATIN1);

    enif_free(memory);
    enif_release_binary(&signature);

    return enif_make_tuple2(env, ok_atom, msg);
}

// Let's define the array of ErlNifFunc beforehand:
static ErlNifFunc nif_funcs[] = {
    // {erl_function_name, erl_function_arity, c_function}
    {"version", 0, version},
    {"create_account", 0, create_account},
    {"pickle_account", 2, pickle_account},
    {"unpickle_account", 2, unpickle_account},
    {"account_identity_keys", 1, account_identity_keys},
    {"account_sign", 2, account_sign},
    {"account_one_time_keys", 1, account_one_time_keys},
    {"account_mark_keys_as_published", 1, account_mark_keys_as_published},
    {"account_max_one_time_keys", 1, account_max_one_time_keys},
    {"account_generate_one_time_keys", 2, account_generate_one_time_keys},
    {"create_outbound_session", 3, create_outbound_session},
    {"create_inbound_session_from", 3, create_inbound_session_from},
    {"encrypt_message_type", 1, encrypt_message_type},
    {"encrypt_message", 2, encrypt_message},
    {"decrypt_message", 3, decrypt_message},
    {"utility_sha256", 1, utility_sha256},
    {"utility_ed25519_verify", 3, utility_ed25519_verify}};

ERL_NIF_INIT(Elixir.Olm.NIF, nif_funcs, nif_load, NULL, NULL, NULL)
