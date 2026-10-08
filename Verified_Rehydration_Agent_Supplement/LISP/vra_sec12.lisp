;;;; vra_sec12.lisp
;;;; AGT-VRA-001 (Verified Rehydration Agent) -- Section 12 "Workflow and State
;;;; Transitions" derived into Common Lisp (LISP lineage, 1958).
;;;;
;;;; Normative content is transcribed from the pack ALONE:
;;;;   - Specification §12 (From | Trigger | Guard | To | On failure): transition model
;;;;   - Specification §12 "Any state | rollback_detected": rollback has
;;;;     BLOCKING PRIORITY over every other restoration rule -> S5 FAIL_SAFE
;;;;   - CT OR-11: S6 remains stable / terminal on the projection surface
;;;;   - Semantic Index TR-008: authority_release canonical successor is S0
;;;;   - Specification §6: verdict vocabulary; §12: state labels
;;;; This is an idiomatic Common Lisp reconstruction. No control logic exists here
;;;; that is not a direct transcription of a spec clause. It is NOT derived from the
;;;; Python/Rust/BF projections; it is derived from the specification.

(defparameter *states*   "012345678")
(defparameter *triggers* "abcdefghi")
;; a=startup_complete  b=snapshot_locked  c=structural_checks_done
;; d=eligibility_checks_done  e=rollback_detected  f=tool-state invalid
;; g=wal_replay_needed  h=recovery_converged  i=authority_release

(defparameter *labels*
  #("S0 STARTUP_READONLY" "S1 SNAPSHOT_LOCKED" "S2 STRUCTURAL_VERIFIED"
    "S3 ELIGIBLE_HEAD_SELECTED" "S4 REHYDRATED_VALIDATED" "S5 FAIL_SAFE"
    "S6 TOOL_QUARANTINE" "S7 RECOVERY_REPLAY" "S8 READMISSION_PENDING"))

(defparameter *verdicts*
  '((#\A . "ALLOW") (#\D . "DENY") (#\Q . "QUARANTINE")
    (#\X . "ESCALATE") (#\R . "READMISSION_PENDING")))

;; Specification §12 transition rows: (from-state trigger pass-target fail-target).
;; Trigger 'e' (rollback_detected) is deliberately NOT a row here -- it is the
;; global blocking-priority rule expressed in NEXT-STATE below.
(defparameter *table*
  '((0 #\a 1 5)    ; S0 startup_complete    / V_BOOT_MODE PASS -> S1 ; fail -> S5
    (1 #\b 2 5)    ; S1 snapshot_locked     / V_SNAPSHOT  PASS -> S2 ; fail -> S5
    (2 #\c 3 5)    ; S2 structural_checks   / V_FRAME..V_SIG   -> S3 ; fail -> S5
    (3 #\d 4 5)    ; S3 eligibility_checks  / freshness+policy+irr+visibility -> S4 ; fail -> S5
    (3 #\f 6 6)    ; S3 tool-state invalid  / tool restrictions failed -> S6 ; remain isolated
    (5 #\g 7 5)    ; Recovery path wal_replay (fixtures drive from S5) -> S7 ; fail -> S5
    (7 #\h 8 5)    ; S7 recovery_converged  / no duplicate effects -> S8 ; fail -> S5
    (8 #\i 0 8)))  ; S8 authority_release   / readmission approved -> S0 (TR-008) ; fail -> remain blocked (S8)

(defun next-state (state trigger guard)
  "STATE is 0..8, TRIGGER a character a..i, GUARD a boolean (did the guard/validator pass?).
Returns an integer next state, or :FAIL-CLOSED when no defined transition applies."
  (cond
    ((char= trigger #\e) 5)              ; rollback_detected: blocking priority over every rule
    ((= state 6) 6)                      ; OR-11: S6 terminal on the projection surface
    (t (let ((row (find-if (lambda (r)
                             (and (= (first r) state) (char= (second r) trigger)))
                           *table*)))
         (if row
             (if guard (third row) (fourth row))
             :fail-closed)))))            ; unmapped (state,trigger): fail-closed reject

(defun render (result)
  (if (eq result :fail-closed) "E" (princ-to-string result)))

;;; ---------------------------------------------------------------------------
;;; Exhaustive 9 x 9 x 2 = 162 sweep. Ordering is matched byte-for-byte to the
;;; BF / Excel reference: state 0..8 (outer), trigger a..i (middle), guard
;;; t then f (inner). The pure 162-token vector goes to STDOUT (one token per
;;; line) so it can be diffed against any other paradigm's output. Diagnostics
;;; go to STDERR.
;;; ---------------------------------------------------------------------------
(let ((total 0)
      (histo (make-hash-table :test 'equal)))
  (loop for sc across *states* do
    (loop for tc across *triggers* do
      (dolist (guard '(t nil))
        (let* ((s (- (char-code sc) (char-code #\0)))
               (tok (render (next-state s tc guard))))
          (incf total)
          (incf (gethash tok histo 0))
          (format t "~a~%" tok)))))
  (format *error-output* "~&;; ---- LISP (SBCL) VRA sec12 sweep ----~%")
  (format *error-output* ";; transition triples emitted: ~d~%" total)
  (let ((keys (sort (loop for k being the hash-keys of histo collect k) #'string<)))
    (format *error-output* ";; output histogram:")
    (dolist (k keys) (format *error-output* " ~a=~d" k (gethash k histo)))
    (format *error-output* "~%"))
  ;; verdict surface (5) and state-label surface (9), reproduced for completeness
  (format *error-output* ";; verdicts (5):")
  (dolist (v *verdicts*) (format *error-output* " ~a=~a" (car v) (cdr v)))
  (format *error-output* "~%;; states (9):")
  (loop for i from 0 below (length *labels*)
        do (format *error-output* " [~a]" (aref *labels* i)))
  (format *error-output* "~%"))
