#!/bin/bash
set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
DBT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DBT_COMMAND="${1:-run}"
LOG_DIR="${AIRFLOW_LOG_DIR:-$DBT_DIR/logs}"
LOG_FILE="$LOG_DIR/dbt_${DBT_COMMAND}_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$LOG_DIR"

# ── Logging helpers ───────────────────────────────────────────────────────────
log() {
    local level="$1"; shift
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo "$msg" | tee -a "$LOG_FILE"
}

info()    { log "INFO " "$@"; }
success() { log "OK   " "$@"; }
error()   { log "ERROR" "$@"; }

# ── Trap for unexpected failures ──────────────────────────────────────────────
trap 'error "Script failed at line $LINENO. Check $LOG_FILE for details."' ERR

# ── Main ──────────────────────────────────────────────────────────────────────
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Starting dbt $DBT_COMMAND"
info "DBT project dir : $DBT_DIR"
info "Log file        : $LOG_FILE"
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DBT_BIN="$(command -v dbt || echo "$DBT_DIR/.venv/bin/dbt")"

info "DBT binary      : $DBT_BIN"

if [[ ! -f "$DBT_BIN" ]]; then
    error "dbt binary not found. Is dbt installed?"
    exit 1
fi

info "Running: dbt $DBT_COMMAND"
cd "$DBT_DIR"
"$DBT_BIN" "$DBT_COMMAND" --profiles-dir "$DBT_DIR" 2>&1 | tee -a "$LOG_FILE"

success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "dbt $DBT_COMMAND completed successfully."
success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
