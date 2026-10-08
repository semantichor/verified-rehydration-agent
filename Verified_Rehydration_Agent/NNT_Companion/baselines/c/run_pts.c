/*
 * run_pts.c — relocatable conformance runner for the Verified Rehydration
 * Agent baseline (AGT-VRA-001), paradigm c.
 *
 * RELOCATABLE: discovers its own directory at runtime (GetModuleFileNameA),
 * chdir()s into it, and drives ".\baseline.exe" and writes pt_run_log.txt /
 * pt_results.json using paths RELATIVE to itself. No absolute machine paths
 * are baked in, so re-running the delivered run_pts.exe beside the delivered
 * baseline.exe reproduces the delivered pt_results.json statuses.
 *
 * Build (beside baseline.exe):
 *   gcc -O3 -s -std=c11 run_pts.c -o run_pts.exe
 * Run:
 *   ./run_pts.exe
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <windows.h>
#include <direct.h>

typedef enum { A_T, A_TSET, A_COMP, A_EV, A_TVS, A_TNEG, A_SKIP } act_t;

typedef struct {
    const char *id;
    const char *cat;   /* runnable | parameterized | declarative */
    act_t       act;
    const char *s, *tg, *pb;         /* transition args (a-call)   */
    const char *exp;                 /* expected id or "S0|S1" set */
    const char *s2, *tg2, *pb2, *exp2; /* composite b-call         */
    const char *fx;                  /* evidence fixture           */
    const char *req;                 /* "|"-joined required keys   */
    const char *kv;                  /* ";"-joined "key=value"     */
    const char *skip;                /* skip reason                */
} pt_t;

static const pt_t PTS[] = {
    {"PT-001","runnable",A_T,"S0","StartupComplete","true","S1",       0,0,0,0, 0,0,0, 0},
    {"PT-002","runnable",A_T,"S2","StructuralChecksDone","true","S3",  0,0,0,0, 0,0,0, 0},
    {"PT-003","runnable",A_T,"S3","EligibilityChecksDone","true","S4", 0,0,0,0, 0,0,0, 0},
    {"PT-004","runnable",A_T,"S2","StructuralChecksDone","false","S5", 0,0,0,0, 0,0,0, 0},
    {"PT-005","runnable",A_T,"S2","StructuralChecksDone","false","S5", 0,0,0,0, 0,0,0, 0},
    {"PT-006","runnable",A_T,"S2","StructuralChecksDone","false","S5", 0,0,0,0, 0,0,0, 0},
    {"PT-007","runnable",A_T,"S2","StructuralChecksDone","false","S5", 0,0,0,0, 0,0,0, 0},
    {"PT-008","runnable",A_T,"S3","EligibilityChecksDone","false","S5",0,0,0,0, 0,0,0, 0},
    {"PT-009","runnable",A_T,"S3","EligibilityChecksDone","false","S5",0,0,0,0, 0,0,0, 0},
    {"PT-010","runnable",A_T,"S0","StartupComplete","false","S5",      0,0,0,0, 0,0,0, 0},
    {"PT-011","runnable",A_T,"S3","RollbackDetected","true","S5",      0,0,0,0, 0,0,0, 0},
    {"PT-012","runnable",A_T,"S5","WalReplayNeeded","true","S7",       0,0,0,0, 0,0,0, 0},
    {"PT-013","runnable",A_T,"S3","ToolStateInvalid","true","S6",      0,0,0,0, 0,0,0, 0},
    {"PT-014","runnable",A_COMP,"S3","ToolStateInvalid","true","S6",
                              "S3","EligibilityChecksDone","true","S4", 0,0,0, 0},
    {"PT-015","runnable",A_T,"S6","StartupComplete","true","S6",       0,0,0,0, 0,0,0, 0},
    {"PT-016","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-01","validator_bundle_id|verified_head_digest|snapshot_id", 0, 0},
    {"PT-017","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-02","validator_bundle_id|verified_head_digest|snapshot_id|policy_id|source_id|freshness_value|irr_digest|tool_activation_status", 0, 0},
    {"PT-018","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-03","failure_code|failed_validator|suppression_status", 0, 0},
    {"PT-019","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-05","recovery_phase|recovery_phase_producer", 0, 0},
    {"PT-020","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-06","readmission_token_id", 0, 0},
    {"PT-021","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-04","", "validator_bundle_id_producer=ExecutionLayer;failure_explanation_producer=GateLogic;tool_activation_status_producer=ToolGate", 0},
    {"PT-022","runnable",A_TVS,0,0,0,0, 0,0,0,0, 0,0,0, 0},
    {"PT-023","runnable",A_TNEG,0,0,0,0, 0,0,0,0, 0,0,0, 0},
    {"PT-024","parameterized",A_TSET,"S8","AuthorityRelease","true","S0|S1", 0,0,0,0, 0,0,0, 0},
    {"PT-025","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-02","freshness_value|policy_id", "failed_validator=V_FRESHNESS", 0},
    {"PT-026","runnable",A_EV,0,0,0,0, 0,0,0,0,
        "EB-05","recovery_phase", "recovery_phase_producer=V_WAL_PHASE", 0},
    {"PT-027","runnable",A_T,"S3","ToolStateInvalid","true","S6",      0,0,0,0, 0,0,0, 0},
    {"PT-028","declarative",A_SKIP,0,0,0,0, 0,0,0,0, 0,0,0,
        "declarative bounded external obligation (V_COMPAT), not locally runnable"},
    {"PT-029","declarative",A_SKIP,0,0,0,0, 0,0,0,0, 0,0,0,
        "declarative bounded external obligation (V_WRITER_LOCK), not locally runnable"},
};
static const int NPT = (int)(sizeof(PTS)/sizeof(PTS[0]));

/* run a command, capture stdout into out (NUL-terminated), return exit code */
static int run_capture(const char *cmd, char *out, size_t outsz)
{
    out[0] = '\0';
    FILE *fp = popen(cmd, "r");
    if (!fp) return -2;
    size_t n = 0;
    int ch;
    while ((ch = fgetc(fp)) != EOF && n + 1 < outsz)
        out[n++] = (char)ch;
    out[n] = '\0';
    int rc = pclose(fp);
    return rc;
}

/* extract value of "key=" (line-anchored) into val; return 1 if found */
static int get_kv(const char *buf, const char *key, char *val, size_t valsz)
{
    size_t klen = strlen(key);
    const char *p = buf;
    while (p && *p) {
        const char *line = p;
        if (strncmp(line, key, klen) == 0 && line[klen] == '=') {
            const char *v = line + klen + 1;
            size_t i = 0;
            while (v[i] && v[i] != '\n' && v[i] != '\r' && i + 1 < valsz) { val[i] = v[i]; i++; }
            val[i] = '\0';
            return 1;
        }
        const char *nl = strchr(p, '\n');
        p = nl ? nl + 1 : NULL;
    }
    val[0] = '\0';
    return 0;
}

/* whole "key=value" line present exactly? */
static int has_kv_exact(const char *buf, const char *kvpair)
{
    const char *eq = strchr(kvpair, '=');
    if (!eq) return 0;
    char key[128], val[256], got[256];
    size_t klen = (size_t)(eq - kvpair);
    if (klen >= sizeof(key)) return 0;
    memcpy(key, kvpair, klen); key[klen] = '\0';
    strncpy(val, eq + 1, sizeof(val) - 1); val[sizeof(val) - 1] = '\0';
    if (!get_kv(buf, key, got, sizeof(got))) return 0;
    return strcmp(got, val) == 0;
}

static void log_block(FILE *log, const char *id, const char *cmd, int exit_code, const char *out)
{
    fprintf(log, "PT-ID: %s\n", id);
    fprintf(log, "COMMAND: %s\n", cmd);
    fprintf(log, "EXIT_CODE: %d\n", exit_code);
    /* small outputs: whole capture is within the 4096-byte tail bound */
    fprintf(log, "STDOUT_TAIL: %s\n", out[0] ? out : "(empty)");
    fprintf(log, "\n");
}

int main(void)
{
    char exepath[MAX_PATH];
    DWORD len = GetModuleFileNameA(NULL, exepath, sizeof(exepath));
    if (len == 0 || len >= sizeof(exepath)) { fprintf(stderr, "cannot locate own path\n"); return 3; }
    /* strip filename -> own directory */
    for (DWORD i = len; i > 0; --i) {
        if (exepath[i-1] == '\\' || exepath[i-1] == '/') { exepath[i-1] = '\0'; break; }
    }
    if (_chdir(exepath) != 0) { fprintf(stderr, "cannot chdir to own dir: %s\n", exepath); return 3; }

    FILE *log = fopen("pt_run_log.txt", "a");
    if (!log) { fprintf(stderr, "cannot open pt_run_log.txt\n"); return 3; }

    int n_pass = 0, n_fail = 0, n_skip = 0, n_error = 0;
    char status[64][8];
    char notes[64][192];

    for (int i = 0; i < NPT; ++i) {
        const pt_t *t = &PTS[i];
        char cmd[512], out[8192], val[256];
        int rc;
        const char *st = "ERROR";
        char note[192]; note[0] = '\0';

        switch (t->act) {
        case A_T: {
            snprintf(cmd, sizeof(cmd), ".\\baseline.exe transition %s %s %s", t->s, t->tg, t->pb);
            rc = run_capture(cmd, out, sizeof(out));
            if (!get_kv(out, "result_state_id", val, sizeof(val))) { st = "ERROR"; snprintf(note,sizeof(note),"no result_state_id in output"); }
            else if (strcmp(val, t->exp) == 0) { st = "PASS"; snprintf(note,sizeof(note),"result_state_id=%s == expected %s", val, t->exp); }
            else { st = "FAIL"; snprintf(note,sizeof(note),"result_state_id=%s != expected %s", val, t->exp); }
            log_block(log, t->id, cmd, rc, out);
            break;
        }
        case A_TSET: {
            snprintf(cmd, sizeof(cmd), ".\\baseline.exe transition %s %s %s", t->s, t->tg, t->pb);
            rc = run_capture(cmd, out, sizeof(out));
            if (!get_kv(out, "result_state_id", val, sizeof(val))) { st = "ERROR"; snprintf(note,sizeof(note),"no result_state_id"); }
            else {
                int member = 0;
                char set[64]; strncpy(set, t->exp, sizeof(set)-1); set[sizeof(set)-1]='\0';
                char *tok = strtok(set, "|");
                while (tok) { if (strcmp(val, tok)==0){member=1;break;} tok = strtok(NULL,"|"); }
                if (member) { st="PASS"; snprintf(note,sizeof(note),"result_state_id=%s in {%s} (declared envelope: approved->S0)", val, t->exp); }
                else { st="FAIL"; snprintf(note,sizeof(note),"result_state_id=%s not in {%s}", val, t->exp); }
            }
            log_block(log, t->id, cmd, rc, out);
            break;
        }
        case A_COMP: {
            char cmdb[512], outb[8192], vala[256], valb[256];
            snprintf(cmd,  sizeof(cmd),  ".\\baseline.exe transition %s %s %s", t->s,  t->tg,  t->pb);
            snprintf(cmdb, sizeof(cmdb), ".\\baseline.exe transition %s %s %s", t->s2, t->tg2, t->pb2);
            rc = run_capture(cmd, out, sizeof(out));
            int rcb = run_capture(cmdb, outb, sizeof(outb));
            int ga = get_kv(out,  "result_state_id", vala, sizeof(vala));
            int gb = get_kv(outb, "result_state_id", valb, sizeof(valb));
            if (!ga || !gb) { st="ERROR"; snprintf(note,sizeof(note),"missing result_state_id in composite calls"); }
            else if (strcmp(vala,t->exp)==0 && strcmp(valb,t->exp2)==0 && strcmp(vala,valb)!=0) {
                st="PASS"; snprintf(note,sizeof(note),"a=%s(exp %s), b=%s(exp %s), distinct", vala,t->exp,valb,t->exp2);
            } else {
                st="FAIL"; snprintf(note,sizeof(note),"a=%s(exp %s), b=%s(exp %s)", vala,t->exp,valb,t->exp2);
            }
            /* one PT-ID block, both internal invocations embedded */
            fprintf(log, "PT-ID: %s\n", t->id);
            fprintf(log, "COMMAND: %s\n", cmd);
            fprintf(log, "EXIT_CODE: %d\n", rc);
            fprintf(log, "STDOUT_TAIL: %s\n", out[0]?out:"(empty)");
            fprintf(log, "COMMAND: %s\n", cmdb);
            fprintf(log, "EXIT_CODE: %d\n", rcb);
            fprintf(log, "STDOUT_TAIL: %s\n", outb[0]?outb:"(empty)");
            fprintf(log, "\n");
            break;
        }
        case A_EV: {
            snprintf(cmd, sizeof(cmd), ".\\baseline.exe evidence %s", t->fx);
            rc = run_capture(cmd, out, sizeof(out));
            int ok = 1; char miss[160]; miss[0]='\0';
            /* required keys present & non-empty */
            if (t->req && t->req[0]) {
                char reqs[512]; strncpy(reqs, t->req, sizeof(reqs)-1); reqs[sizeof(reqs)-1]='\0';
                char *tok = strtok(reqs, "|");
                while (tok) {
                    if (!get_kv(out, tok, val, sizeof(val)) || val[0]=='\0') { ok=0; snprintf(miss+strlen(miss),sizeof(miss)-strlen(miss),"[%s]",tok); }
                    tok = strtok(NULL,"|");
                }
            }
            /* exact key=value checks */
            if (t->kv && t->kv[0]) {
                char kvs[512]; strncpy(kvs, t->kv, sizeof(kvs)-1); kvs[sizeof(kvs)-1]='\0';
                char *tok = strtok(kvs, ";");
                while (tok) {
                    if (!has_kv_exact(out, tok)) { ok=0; snprintf(miss+strlen(miss),sizeof(miss)-strlen(miss),"[!%s]",tok); }
                    tok = strtok(NULL,";");
                }
            }
            if (ok) { st="PASS"; snprintf(note,sizeof(note),"%s: required fields present", t->fx); }
            else    { st="FAIL"; snprintf(note,sizeof(note),"%s: missing %s", t->fx, miss); }
            log_block(log, t->id, cmd, rc, out);
            break;
        }
        case A_TVS: {
            snprintf(cmd, sizeof(cmd), ".\\baseline.exe taxonomy verdict-state");
            rc = run_capture(cmd, out, sizeof(out));
            if (get_kv(out,"distinct",val,sizeof(val)) && strcmp(val,"true")==0) { st="PASS"; snprintf(note,sizeof(note),"verdict tag vs state tag distinct"); }
            else { st="FAIL"; snprintf(note,sizeof(note),"distinct!=true"); }
            log_block(log, t->id, cmd, rc, out);
            break;
        }
        case A_TNEG: {
            snprintf(cmd, sizeof(cmd), ".\\baseline.exe taxonomy negatives");
            rc = run_capture(cmd, out, sizeof(out));
            if (get_kv(out,"pairwise_distinct",val,sizeof(val)) && strcmp(val,"true")==0) { st="PASS"; snprintf(note,sizeof(note),"DENY/ESCALATE/QUARANTINE pairwise distinct"); }
            else { st="FAIL"; snprintf(note,sizeof(note),"pairwise_distinct!=true"); }
            log_block(log, t->id, cmd, rc, out);
            break;
        }
        case A_SKIP:
        default: {
            st = "SKIP";
            snprintf(note, sizeof(note), "%s", t->skip ? t->skip : "not locally runnable");
            fprintf(log, "PT-ID: %s\n", t->id);
            fprintf(log, "COMMAND: (no invocation -- SKIP: %s)\n", note);
            fprintf(log, "EXIT_CODE: -1\n");
            fprintf(log, "STDOUT_TAIL: (not invoked; see pt_results.json notes)\n\n");
            break;
        }
        }

        strncpy(status[i], st, sizeof(status[i])-1); status[i][sizeof(status[i])-1]='\0';
        strncpy(notes[i], note, sizeof(notes[i])-1); notes[i][sizeof(notes[i])-1]='\0';
        if      (!strcmp(st,"PASS")) n_pass++;
        else if (!strcmp(st,"FAIL")) n_fail++;
        else if (!strcmp(st,"SKIP")) n_skip++;
        else                          n_error++;
    }
    fclose(log);

    /* timestamp (UTC ISO-8601) */
    char ts[32];
    time_t now = time(NULL);
    struct tm *g = gmtime(&now);
    strftime(ts, sizeof(ts), "%Y-%m-%dT%H:%M:%SZ", g);

    FILE *js = fopen("pt_results.json", "w");
    if (!js) { fprintf(stderr, "cannot write pt_results.json\n"); return 3; }
    fprintf(js, "{\n");
    fprintf(js, "  \"agent_id\": \"AGT-VRA-001\",\n");
    fprintf(js, "  \"lang\": \"c\",\n");
    fprintf(js, "  \"test_run_timestamp_utc\": \"%s\",\n", ts);
    fprintf(js, "  \"execution_mode\": \"live\",\n");
    fprintf(js, "  \"protocol\": \"buyer-conformance\",\n");
    fprintf(js, "  \"totals\": {\"total\": %d, \"pass\": %d, \"fail\": %d, \"skip\": %d, \"error\": %d},\n",
            NPT, n_pass, n_fail, n_skip, n_error);
    fprintf(js, "  \"results\": [\n");
    for (int i = 0; i < NPT; ++i) {
        fprintf(js, "    {\"id\": \"%s\", \"category\": \"%s\", \"status\": \"%s\", \"notes\": \"%s\"}%s\n",
                PTS[i].id, PTS[i].cat, status[i], notes[i], (i+1<NPT)?",":"");
    }
    fprintf(js, "  ]\n");
    fprintf(js, "}\n");
    fclose(js);

    printf("run_pts complete: total=%d pass=%d fail=%d skip=%d error=%d\n",
           NPT, n_pass, n_fail, n_skip, n_error);
    return 0;
}
