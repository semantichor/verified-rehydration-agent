/*
 * baseline.c — Verified Rehydration Agent (AGT-VRA-001), paradigm: c
 *
 * Live, execution-neutral transcription of the agent's specified behavior into
 * idiomatic C. Derived solely from the 11 buyer-facing pack files.
 *
 * Idioms (R4):
 *   - Function-pointer table (transition_fn_t handlers[state][trigger]) for
 *     state-event dispatch (Spec S12 Transition model).
 *   - enums for states, triggers, verdicts; enum switches carry no default so
 *     the compiler (-Wswitch) flags any unhandled enumerator.
 *   - assert() for invariants (bounds, contract validity).
 *   - struct-based contracts (input_contract_t, evidence_t) with field
 *     validators called explicitly.
 *
 * Projection surface (Conformance Tests S4 Minimal Run Note):
 *   next_state(current_state, trigger, validator_passed) + an evidence surface.
 *
 * CLI:
 *   baseline transition <STATE> <TRIGGER> <true|false>
 *   baseline evidence   <FIXTURE>            (EB-01..EB-06)
 *   baseline taxonomy   verdict-state | negatives
 */

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

/* ------------------------------------------------------------------ */
/* Enumerations (Spec S6 verdicts, S12 states, S12 transition triggers) */
/* ------------------------------------------------------------------ */

typedef enum {
    S0_STARTUP_READONLY = 0,
    S1_SNAPSHOT_LOCKED,
    S2_STRUCTURAL_VERIFIED,
    S3_ELIGIBLE_HEAD_SELECTED,
    S4_REHYDRATED_VALIDATED,
    S5_FAIL_SAFE,
    S6_TOOL_QUARANTINE,
    S7_RECOVERY_REPLAY,
    S8_READMISSION_PENDING,
    NUM_STATES
} state_t;

typedef enum {
    TRG_STARTUP_COMPLETE = 0,     /* TR-001 startup_complete       */
    TRG_SNAPSHOT_LOCKED,          /* TR-002 snapshot_locked        */
    TRG_STRUCTURAL_CHECKS_DONE,   /* TR-003 structural_checks_done */
    TRG_ELIGIBILITY_CHECKS_DONE,  /* TR-004 eligibility_checks_done*/
    TRG_ROLLBACK_DETECTED,        /* TR-005 rollback_detected      */
    TRG_WAL_REPLAY_NEEDED,        /* TR-006 wal_replay_needed      */
    TRG_RECOVERY_CONVERGED,       /* TR-007 recovery_converged     */
    TRG_AUTHORITY_RELEASE,        /* TR-008 authority_release      */
    TRG_TOOL_STATE_INVALID,       /* S12: "tool-state invalid"     */
    NUM_TRIGGERS,
    TRG_UNKNOWN                   /* unparsable trigger token      */
} trigger_t;

typedef enum {
    VER_ALLOW = 0,                /* DE-010 */
    VER_DENY,                     /* DE-011 */
    VER_QUARANTINE,               /* DE-012 */
    VER_ESCALATE,                 /* DE-013 */
    VER_READMISSION_PENDING,      /* DE-014 */
    NUM_VERDICTS
} verdict_t;

/* ------------------------------------------------------------------ */
/* Label helpers — enum switches with no default (-Wswitch coverage)  */
/* ------------------------------------------------------------------ */

static const char *state_label(state_t s)
{
    switch (s) {
    case S0_STARTUP_READONLY:      return "S0 STARTUP_READONLY";
    case S1_SNAPSHOT_LOCKED:       return "S1 SNAPSHOT_LOCKED";
    case S2_STRUCTURAL_VERIFIED:   return "S2 STRUCTURAL_VERIFIED";
    case S3_ELIGIBLE_HEAD_SELECTED:return "S3 ELIGIBLE_HEAD_SELECTED";
    case S4_REHYDRATED_VALIDATED:  return "S4 REHYDRATED_VALIDATED";
    case S5_FAIL_SAFE:             return "S5 FAIL_SAFE";
    case S6_TOOL_QUARANTINE:       return "S6 TOOL_QUARANTINE";
    case S7_RECOVERY_REPLAY:       return "S7 RECOVERY_REPLAY";
    case S8_READMISSION_PENDING:   return "S8 READMISSION_PENDING";
    case NUM_STATES:               break;
    }
    return "S?_UNKNOWN";
}

static const char *state_id(state_t s)
{
    switch (s) {
    case S0_STARTUP_READONLY:      return "S0";
    case S1_SNAPSHOT_LOCKED:       return "S1";
    case S2_STRUCTURAL_VERIFIED:   return "S2";
    case S3_ELIGIBLE_HEAD_SELECTED:return "S3";
    case S4_REHYDRATED_VALIDATED:  return "S4";
    case S5_FAIL_SAFE:             return "S5";
    case S6_TOOL_QUARANTINE:       return "S6";
    case S7_RECOVERY_REPLAY:       return "S7";
    case S8_READMISSION_PENDING:   return "S8";
    case NUM_STATES:               break;
    }
    return "S?";
}

static const char *verdict_label(verdict_t v)
{
    switch (v) {
    case VER_ALLOW:               return "ALLOW";
    case VER_DENY:                return "DENY";
    case VER_QUARANTINE:          return "QUARANTINE";
    case VER_ESCALATE:            return "ESCALATE";
    case VER_READMISSION_PENDING: return "READMISSION_PENDING";
    case NUM_VERDICTS:            break;
    }
    return "UNKNOWN";
}

/* ------------------------------------------------------------------ */
/* Input contract (Spec S4) — struct + explicit field validators      */
/* ------------------------------------------------------------------ */

typedef struct {
    state_t   current_state;
    trigger_t trigger;
    bool      validator_passed;
} input_contract_t;

static bool state_in_range(state_t s)   { return s >= 0 && s < NUM_STATES; }
static bool trigger_in_range(trigger_t t){ return t >= 0 && t < NUM_TRIGGERS; }

static bool validate_input_contract(const input_contract_t *ic)
{
    assert(ic != NULL);
    return state_in_range(ic->current_state) && trigger_in_range(ic->trigger);
}

/* ------------------------------------------------------------------ */
/* Transition handlers (Spec S12 Transition model rows)               */
/* transition_fn_t: (current, validator_passed) -> next state         */
/* ------------------------------------------------------------------ */

typedef state_t (*transition_fn_t)(state_t current, bool validator_passed);

/* S0 | startup_complete | V_BOOT_MODE PASS | S1 | on failure S5      */
static state_t h_s0_startup(state_t cur, bool pass)
{ (void)cur; return pass ? S1_SNAPSHOT_LOCKED : S5_FAIL_SAFE; }

/* S1 | snapshot_locked | V_SNAPSHOT PASS | S2 | on failure S5        */
static state_t h_s1_snapshot(state_t cur, bool pass)
{ (void)cur; return pass ? S2_STRUCTURAL_VERIFIED : S5_FAIL_SAFE; }

/* S2 | structural_checks_done | V_FRAME..V_SIG PASS | S3 | S5        */
static state_t h_s2_structural(state_t cur, bool pass)
{ (void)cur; return pass ? S3_ELIGIBLE_HEAD_SELECTED : S5_FAIL_SAFE; }

/* S3 | eligibility_checks_done | V_FRESHNESS+V_POLICY+V_IRR+V_VISIBILITY | S4 | S5 */
static state_t h_s3_eligibility(state_t cur, bool pass)
{ (void)cur; return pass ? S4_REHYDRATED_VALIDATED : S5_FAIL_SAFE; }

/* S3 | tool-state invalid | Tool restrictions failed | S6 | Remain isolated.
 * The trigger itself signals tool-state invalidity, so it routes to S6
 * independent of the mainline validator gate (Spec S12; AR-006 keeps the
 * tool-state path distinct from conversational restoration).            */
static state_t h_s3_toolstate(state_t cur, bool pass)
{ (void)cur; (void)pass; return S6_TOOL_QUARANTINE; }

/* Recovery path | wal_replay_needed | V_WAL_PHASE indicates recovery | S7 | S5 */
static state_t h_walreplay(state_t cur, bool pass)
{ (void)cur; return pass ? S7_RECOVERY_REPLAY : S5_FAIL_SAFE; }

/* S7 | recovery_converged | No duplicate effects | S8 | S5           */
static state_t h_s7_recovery(state_t cur, bool pass)
{ (void)cur; return pass ? S8_READMISSION_PENDING : S5_FAIL_SAFE; }

/* S8 | authority_release | Readmission approved | S0 or S1 | Remain blocked.
 * Declared buyer envelope (PT-024 / OR-20 admissible set {S0,S1}): an approved
 * readmission returns to S0 STARTUP_READONLY for a full re-verification pass;
 * a non-approved release remains blocked in S8 (Spec S12 "Remain blocked").  */
static state_t h_s8_authrelease(state_t cur, bool pass)
{ (void)cur; return pass ? S0_STARTUP_READONLY : S8_READMISSION_PENDING; }

/* Dispatch table: [state][trigger] -> handler (NULL = unmapped).      */
static transition_fn_t g_handlers[NUM_STATES][NUM_TRIGGERS];

static void init_handlers(void)
{
    memset(g_handlers, 0, sizeof(g_handlers));
    g_handlers[S0_STARTUP_READONLY][TRG_STARTUP_COMPLETE]      = h_s0_startup;
    g_handlers[S1_SNAPSHOT_LOCKED][TRG_SNAPSHOT_LOCKED]        = h_s1_snapshot;
    g_handlers[S2_STRUCTURAL_VERIFIED][TRG_STRUCTURAL_CHECKS_DONE] = h_s2_structural;
    g_handlers[S3_ELIGIBLE_HEAD_SELECTED][TRG_ELIGIBILITY_CHECKS_DONE] = h_s3_eligibility;
    g_handlers[S3_ELIGIBLE_HEAD_SELECTED][TRG_TOOL_STATE_INVALID] = h_s3_toolstate;
    g_handlers[S5_FAIL_SAFE][TRG_WAL_REPLAY_NEEDED]           = h_walreplay;
    g_handlers[S7_RECOVERY_REPLAY][TRG_RECOVERY_CONVERGED]     = h_s7_recovery;
    g_handlers[S8_READMISSION_PENDING][TRG_AUTHORITY_RELEASE]  = h_s8_authrelease;
}

/*
 * next_state — the required projection surface.
 *
 * Ordering of rules (Spec S7:142 "Rollback detection has blocking priority over
 * every other restoration rule"; S12 "Any state | rollback_detected -> S5"):
 *   1. rollback_detected forces S5 from any state, ignoring the gate.
 *   2. a mapped (state,trigger) cell fires its handler.
 *   3. an unmapped (state,trigger) is fail-closed: the machine stays in the
 *      current state and never spuriously advances toward S4/ALLOW (Spec S2
 *      core invariant: no restoration before the full sequence completes).
 *      This makes terminal/isolation states stable (e.g. S6 stays S6, PT-015).
 */
static state_t next_state(state_t current, trigger_t trigger, bool validator_passed)
{
    input_contract_t ic = { current, trigger, validator_passed };
    assert(validate_input_contract(&ic));

    if (trigger == TRG_ROLLBACK_DETECTED)
        return S5_FAIL_SAFE;

    transition_fn_t fn = g_handlers[current][trigger];
    if (fn == NULL)
        return current;                 /* fail-closed identity default */
    return fn(current, validator_passed);
}

/* Observability projection: verdict class implied by a resulting state. */
static const char *state_verdict_hint(state_t s)
{
    switch (s) {
    case S4_REHYDRATED_VALIDATED:  return verdict_label(VER_DENY);
    case S5_FAIL_SAFE:             return verdict_label(VER_DENY);
    case S6_TOOL_QUARANTINE:       return verdict_label(VER_QUARANTINE);
    case S7_RECOVERY_REPLAY:       return verdict_label(VER_QUARANTINE);
    case S8_READMISSION_PENDING:   return verdict_label(VER_READMISSION_PENDING);
    case S0_STARTUP_READONLY:
    case S1_SNAPSHOT_LOCKED:
    case S2_STRUCTURAL_VERIFIED:
    case S3_ELIGIBLE_HEAD_SELECTED:return "IN_PROGRESS";
    case NUM_STATES:               break;
    }
    return "UNKNOWN";
}

/* ------------------------------------------------------------------ */
/* Argument parsing: string tokens -> enums (input-boundary decoders)  */
/* ------------------------------------------------------------------ */

static state_t parse_state(const char *tok)
{
    if (tok == NULL) return NUM_STATES;
    if (!strcmp(tok, "S0") || !strcmp(tok, "S0_STARTUP_READONLY"))       return S0_STARTUP_READONLY;
    if (!strcmp(tok, "S1") || !strcmp(tok, "S1_SNAPSHOT_LOCKED"))        return S1_SNAPSHOT_LOCKED;
    if (!strcmp(tok, "S2") || !strcmp(tok, "S2_STRUCTURAL_VERIFIED"))    return S2_STRUCTURAL_VERIFIED;
    if (!strcmp(tok, "S3") || !strcmp(tok, "S3_ELIGIBLE_HEAD_SELECTED")) return S3_ELIGIBLE_HEAD_SELECTED;
    if (!strcmp(tok, "S4") || !strcmp(tok, "S4_REHYDRATED_VALIDATED"))   return S4_REHYDRATED_VALIDATED;
    if (!strcmp(tok, "S5") || !strcmp(tok, "S5_FAIL_SAFE"))              return S5_FAIL_SAFE;
    if (!strcmp(tok, "S6") || !strcmp(tok, "S6_TOOL_QUARANTINE"))        return S6_TOOL_QUARANTINE;
    if (!strcmp(tok, "S7") || !strcmp(tok, "S7_RECOVERY_REPLAY"))        return S7_RECOVERY_REPLAY;
    if (!strcmp(tok, "S8") || !strcmp(tok, "S8_READMISSION_PENDING"))    return S8_READMISSION_PENDING;
    return NUM_STATES;
}

static trigger_t parse_trigger(const char *tok)
{
    if (tok == NULL) return TRG_UNKNOWN;
    if (!strcmp(tok, "StartupComplete")      || !strcmp(tok, "startup_complete"))       return TRG_STARTUP_COMPLETE;
    if (!strcmp(tok, "SnapshotLocked")       || !strcmp(tok, "snapshot_locked"))        return TRG_SNAPSHOT_LOCKED;
    if (!strcmp(tok, "StructuralChecksDone") || !strcmp(tok, "structural_checks_done")) return TRG_STRUCTURAL_CHECKS_DONE;
    if (!strcmp(tok, "EligibilityChecksDone")|| !strcmp(tok, "eligibility_checks_done"))return TRG_ELIGIBILITY_CHECKS_DONE;
    if (!strcmp(tok, "RollbackDetected")     || !strcmp(tok, "rollback_detected"))      return TRG_ROLLBACK_DETECTED;
    if (!strcmp(tok, "WalReplayNeeded")      || !strcmp(tok, "wal_replay_needed"))      return TRG_WAL_REPLAY_NEEDED;
    if (!strcmp(tok, "RecoveryConverged")    || !strcmp(tok, "recovery_converged"))     return TRG_RECOVERY_CONVERGED;
    if (!strcmp(tok, "AuthorityRelease")     || !strcmp(tok, "authority_release"))      return TRG_AUTHORITY_RELEASE;
    if (!strcmp(tok, "ToolStateInvalid")     || !strcmp(tok, "tool_state_invalid"))     return TRG_TOOL_STATE_INVALID;
    return TRG_UNKNOWN;
}

static bool parse_bool(const char *tok)
{
    if (tok == NULL) return false;
    return (!strcmp(tok, "true") || !strcmp(tok, "1") || !strcmp(tok, "TRUE") || !strcmp(tok, "pass"));
}

/* ------------------------------------------------------------------ */
/* Evidence contract (Spec S14) — struct + explicit field validators   */
/* ------------------------------------------------------------------ */

typedef struct {
    const char *bundle_class;
    const char *validator_bundle_id;
    const char *validator_bundle_id_producer;
    const char *verified_head_digest;
    const char *accepted_head_digest;
    const char *snapshot_id;
    const char *policy_id;
    const char *source_id;
    const char *freshness_value;
    const char *irr_digest;
    const char *failed_validator;
    const char *failure_code;
    const char *failure_explanation_producer;
    const char *suppression_status;
    const char *tool_activation_status;
    const char *tool_activation_status_producer;
    const char *recovery_phase;
    const char *recovery_phase_producer;
    const char *writer_lock_status;
    const char *contention_status;
    const char *readmission_token_id;
} evidence_t;

/* explicit field validator: emit "key=value" only when value is non-empty */
static void emit_field(const char *key, const char *value)
{
    if (value != NULL && value[0] != '\0')
        printf("%s=%s\n", key, value);
}

static void emit_evidence(const evidence_t *e)
{
    assert(e != NULL);
    emit_field("bundle_class",                    e->bundle_class);
    emit_field("validator_bundle_id",             e->validator_bundle_id);
    emit_field("validator_bundle_id_producer",    e->validator_bundle_id_producer);
    emit_field("verified_head_digest",            e->verified_head_digest);
    emit_field("accepted_head_digest",            e->accepted_head_digest);
    emit_field("snapshot_id",                     e->snapshot_id);
    emit_field("policy_id",                       e->policy_id);
    emit_field("source_id",                       e->source_id);
    emit_field("freshness_value",                 e->freshness_value);
    emit_field("irr_digest",                      e->irr_digest);
    emit_field("failed_validator",                e->failed_validator);
    emit_field("failure_code",                    e->failure_code);
    emit_field("failure_explanation_producer",    e->failure_explanation_producer);
    emit_field("suppression_status",              e->suppression_status);
    emit_field("tool_activation_status",          e->tool_activation_status);
    emit_field("tool_activation_status_producer", e->tool_activation_status_producer);
    emit_field("recovery_phase",                  e->recovery_phase);
    emit_field("recovery_phase_producer",         e->recovery_phase_producer);
    emit_field("writer_lock_status",              e->writer_lock_status);
    emit_field("contention_status",               e->contention_status);
    emit_field("readmission_token_id",            e->readmission_token_id);
}

/*
 * A representative DENY-path bundle. The minimum bundle for the principal
 * verdict (Spec S14) carries validator_bundle_id, verified_head_digest,
 * snapshot_id, policy_id, source_id, freshness_value, irr_digest,
 * failed_validator, failure_code, suppression_status, tool_activation_status.
 * Producer tags per PT-021/OR-17. failed_validator differs per fixture class.
 */
static evidence_t make_deny_bundle(const char *failed_validator)
{
    evidence_t e = {0};
    e.bundle_class                    = "DENY";
    e.validator_bundle_id             = "VB-0001";
    e.validator_bundle_id_producer    = "ExecutionLayer";
    e.verified_head_digest            = "sha256:vh-cafef00d";
    e.accepted_head_digest            = "sha256:ah-cafef00d";
    e.snapshot_id                     = "SNAP-0001";
    e.policy_id                       = "POL-0001";
    e.source_id                       = "SRC-0001";
    e.freshness_value                 = "42";
    e.irr_digest                      = "sha256:irr-9a9a";
    e.failed_validator                = failed_validator;
    e.failure_code                    = "FC-DENY-001";
    e.failure_explanation_producer    = "GateLogic";
    e.suppression_status              = "suppressed";
    e.tool_activation_status          = "inactive";
    e.tool_activation_status_producer = "ToolGate";
    return e;
}

static evidence_t make_recovery_bundle(void)
{
    evidence_t e = {0};
    e.bundle_class                 = "RECOVERY";
    e.validator_bundle_id          = "VB-0002";
    e.validator_bundle_id_producer = "ExecutionLayer";
    e.snapshot_id                  = "SNAP-0002";
    e.recovery_phase               = "converging";
    e.recovery_phase_producer      = "V_WAL_PHASE";
    e.tool_activation_status       = "inactive";
    e.tool_activation_status_producer = "ToolGate";
    e.writer_lock_status           = "held";
    e.contention_status            = "none";
    return e;
}

static evidence_t make_readmission_bundle(void)
{
    evidence_t e = {0};
    e.bundle_class                 = "READMISSION";
    e.validator_bundle_id          = "VB-0003";
    e.validator_bundle_id_producer = "ExecutionLayer";
    e.snapshot_id                  = "SNAP-0003";
    e.recovery_phase               = "converged";
    e.recovery_phase_producer      = "V_WAL_PHASE";
    e.tool_activation_status       = "inactive";
    e.tool_activation_status_producer = "ToolGate";
    e.readmission_token_id         = "RT-0001";
    return e;
}

static int cmd_evidence(const char *fixture)
{
    evidence_t e;
    if      (!strcmp(fixture, "EB-01")) e = make_deny_bundle("V_CHAIN");
    else if (!strcmp(fixture, "EB-02")) e = make_deny_bundle("V_FRESHNESS");
    else if (!strcmp(fixture, "EB-03")) e = make_deny_bundle("V_PARSE");
    else if (!strcmp(fixture, "EB-04")) e = make_deny_bundle("V_FRAME");
    else if (!strcmp(fixture, "EB-05")) e = make_recovery_bundle();
    else if (!strcmp(fixture, "EB-06")) e = make_readmission_bundle();
    else { fprintf(stderr, "unknown fixture: %s\n", fixture); return 2; }

    printf("op=evidence\n");
    printf("fixture=%s\n", fixture);
    emit_evidence(&e);
    return 0;
}

static int cmd_transition(const char *s_tok, const char *t_tok, const char *b_tok)
{
    state_t st = parse_state(s_tok);
    trigger_t tr = parse_trigger(t_tok);
    bool pass = parse_bool(b_tok);

    if (!state_in_range(st)) { fprintf(stderr, "unknown state: %s\n", s_tok ? s_tok : "(null)"); return 2; }

    /* An unknown trigger is treated as unmapped (fail-closed identity). */
    trigger_t tr_eff = trigger_in_range(tr) ? tr : TRG_STARTUP_COMPLETE;
    state_t result;
    if (!trigger_in_range(tr)) {
        result = st;   /* unmapped: identity */
        (void)tr_eff;
    } else {
        result = next_state(st, tr, pass);
    }

    printf("op=transition\n");
    printf("input_state=%s\n", state_label(st));
    printf("input_trigger=%s\n", (t_tok ? t_tok : "(null)"));
    printf("validator_passed=%s\n", pass ? "true" : "false");
    printf("result_state_id=%s\n", state_id(result));
    printf("result_state=%s\n", state_label(result));
    printf("verdict_hint=%s\n", state_verdict_hint(result));
    return 0;
}

static int cmd_taxonomy(const char *which)
{
    if (!strcmp(which, "verdict-state")) {
        /* PT-022 / VT-01: verdict tag QUARANTINE vs state tag S6 TOOL_QUARANTINE.
         * They are distinct symbol spaces (a verdict enum vs a state enum);
         * AR-003 keeps verdict, state label, and MRF form distinct.          */
        printf("op=taxonomy\n");
        printf("verdict_tag=NormativeVerdict::%s\n", verdict_label(VER_QUARANTINE));
        printf("state_tag=WorkflowState::%s\n", "S6ToolQuarantine");
        printf("distinct=%s\n", "true");
        return 0;
    }
    if (!strcmp(which, "negatives")) {
        /* PT-023 / VT-02: DENY, ESCALATE, QUARANTINE discriminants pairwise
         * distinct — guaranteed by distinct enum values.                     */
        int d = (int)VER_DENY, es = (int)VER_ESCALATE, q = (int)VER_QUARANTINE;
        bool distinct = (d != es) && (d != q) && (es != q);
        printf("op=taxonomy\n");
        printf("deny_discriminant=%d\n", d);
        printf("escalate_discriminant=%d\n", es);
        printf("quarantine_discriminant=%d\n", q);
        printf("pairwise_distinct=%s\n", distinct ? "true" : "false");
        return 0;
    }
    fprintf(stderr, "unknown taxonomy selector: %s\n", which);
    return 2;
}

static void usage(void)
{
    fprintf(stderr,
        "usage:\n"
        "  baseline transition <STATE> <TRIGGER> <true|false>\n"
        "  baseline evidence   <EB-01..EB-06>\n"
        "  baseline taxonomy   verdict-state|negatives\n");
}

int main(int argc, char **argv)
{
    init_handlers();

    if (argc < 2) { usage(); return 2; }

    if (!strcmp(argv[1], "transition")) {
        if (argc < 5) { usage(); return 2; }
        return cmd_transition(argv[2], argv[3], argv[4]);
    }
    if (!strcmp(argv[1], "evidence")) {
        if (argc < 3) { usage(); return 2; }
        return cmd_evidence(argv[2]);
    }
    if (!strcmp(argv[1], "taxonomy")) {
        if (argc < 3) { usage(); return 2; }
        return cmd_taxonomy(argv[2]);
    }

    usage();
    return 2;
}
