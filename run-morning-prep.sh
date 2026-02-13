#!/usr/bin/env bash
#
# run-morning-prep.sh - Morning trading prep orchestrator
#
# Runs Claude Code to generate a trading prep report, converts to HTML,
# and emails it. Designed to run via cron at ~5:30 AM ET before markets open.
#
# Exit codes:
#   0 - Success
#   1 - Report generation failure
#   2 - Email delivery failure
#   3 - Missing dependency
#
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
PREP_DIR="$HOME/projects/trading-prep"
CLAUDE_BIN="$HOME/.local/bin/claude"
EMAIL_TO="daryll@bigpicsolutions.com"
TIMEOUT_SECONDS=2700  # 45 minutes
TODAY=$(date +%Y-%m-%d)
REPORT_FILE="$PREP_DIR/reports/trading-prep-${TODAY}.md"
LOG_FILE="$PREP_DIR/logs/prep-${TODAY}.log"
HTML_FILE="$PREP_DIR/reports/trading-prep-${TODAY}.html"
PROMPT_FILE="$PREP_DIR/morning-prompt.md"
TEMPLATE_FILE="$PREP_DIR/templates/email-dark.html5"

# ── Logging ──────────────────────────────────────────────────────────────────
mkdir -p "$PREP_DIR/logs" "$PREP_DIR/reports"

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

log_error() {
    log "ERROR: $1"
}

# ── Error trap ───────────────────────────────────────────────────────────────
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script exited with code $exit_code"
    fi
}
trap cleanup EXIT

# ── Dependency checks ────────────────────────────────────────────────────────
check_deps() {
    local missing=0

    if [[ ! -x "$CLAUDE_BIN" ]]; then
        log_error "Claude binary not found at $CLAUDE_BIN"
        missing=1
    fi

    if ! command -v pandoc &>/dev/null; then
        log_error "pandoc is not installed (sudo apt install pandoc)"
        missing=1
    fi

    if ! command -v msmtp &>/dev/null; then
        log_error "msmtp is not installed (sudo apt install msmtp)"
        missing=1
    fi

    if [[ ! -f "$PROMPT_FILE" ]]; then
        log_error "Prompt file not found at $PROMPT_FILE"
        missing=1
    fi

    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_error "HTML template not found at $TEMPLATE_FILE"
        missing=1
    fi

    if [[ $missing -ne 0 ]]; then
        exit 3
    fi
}

# ── HTML email generation (dark theme via template) ──────────────────────────
generate_html_email() {
    local md_file="$1"
    local html_file="$2"

    pandoc "$md_file" \
        --from markdown \
        --to html5 \
        --standalone \
        --embed-resources \
        --metadata title="Morning Trading Prep - $TODAY" \
        --template="$TEMPLATE_FILE" \
        -o "$html_file"

    # Post-process: colorize priority markers in the HTML
    sed -i 's/🔴/<span style="color:#ff4444;font-weight:bold">🔴<\/span>/g' "$html_file"
    sed -i 's/🟡/<span style="color:#ffaa00;font-weight:bold">🟡<\/span>/g' "$html_file"
    sed -i 's/🟢/<span style="color:#44ff44;font-weight:bold">🟢<\/span>/g' "$html_file"

    log "HTML report generated: $html_file"
}

# ── Send email ───────────────────────────────────────────────────────────────
send_email() {
    local subject="$1"
    local html_file="$2"

    {
        echo "From: trading-prep@$(hostname)"
        echo "To: $EMAIL_TO"
        echo "Subject: $subject"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/html; charset=utf-8"
        echo ""
        cat "$html_file"
    } | msmtp "$EMAIL_TO"
}

send_failure_alert() {
    local reason="$1"
    local log_tail=""

    if [[ -f "$LOG_FILE" ]]; then
        log_tail=$(tail -50 "$LOG_FILE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    fi

    local alert_html
    alert_html=$(cat <<EOF
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"/></head>
<body style="background-color:#1a1a2e;color:#e0e0e0;font-family:sans-serif;padding:24px;">
<h1 style="color:#ff4444;">Morning Prep Failed - $TODAY</h1>
<p><strong>Reason:</strong> $reason</p>
<h2 style="color:#ffaa00;">Last 50 Log Lines</h2>
<pre style="background:#0f0f23;border:1px solid #2a2a4a;padding:16px;overflow-x:auto;font-size:13px;color:#e0e0e0;">$log_tail</pre>
</body>
</html>
EOF
    )

    echo "$alert_html" | {
        echo "From: trading-prep@$(hostname)"
        echo "To: $EMAIL_TO"
        echo "Subject: [FAILED] Morning Trading Prep - $TODAY"
        echo "MIME-Version: 1.0"
        echo "Content-Type: text/html; charset=utf-8"
        echo ""
        cat -
    } | msmtp "$EMAIL_TO"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    log "=== Morning Trading Prep Started ==="
    log "Date: $TODAY"
    log "Report: $REPORT_FILE"

    # Check dependencies
    check_deps
    log "All dependencies verified"

    # Run Claude with the morning prompt
    log "Running Claude Code (timeout: ${TIMEOUT_SECONDS}s)..."
    local claude_exit=0
    local prompt_content
    prompt_content=$(cat "$PROMPT_FILE")

    set +e
    timeout --kill-after=30 "$TIMEOUT_SECONDS" "$CLAUDE_BIN" \
        --model opus \
        -p "$prompt_content" \
        --dangerously-skip-permissions \
        >> "$LOG_FILE" 2>&1
    claude_exit=$?
    set -e

    if [[ $claude_exit -eq 124 ]]; then
        log_error "Claude timed out (SIGTERM) after ${TIMEOUT_SECONDS}s"
        send_failure_alert "Claude timed out (SIGTERM) after ${TIMEOUT_SECONDS} seconds" || true
        exit 1
    elif [[ $claude_exit -eq 137 ]]; then
        log_error "Claude timed out (SIGKILL) after $((TIMEOUT_SECONDS + 30))s — process ignored SIGTERM"
        send_failure_alert "Claude had to be force-killed (SIGKILL) — ignored SIGTERM for 30s" || true
        exit 1
    elif [[ $claude_exit -ne 0 ]]; then
        log_error "Claude exited with code $claude_exit"
        send_failure_alert "Claude exited with code $claude_exit" || true
        exit 1
    fi

    log "Claude finished successfully"

    # Check if report was generated
    if [[ ! -f "$REPORT_FILE" ]]; then
        log_error "Report file not found at $REPORT_FILE"
        send_failure_alert "Report file was not created by Claude" || true
        exit 1
    fi

    local report_size
    report_size=$(stat -c%s "$REPORT_FILE")
    log "Report generated: $REPORT_FILE ($report_size bytes)"

    if [[ $report_size -lt 100 ]]; then
        log_error "Report seems too small ($report_size bytes), may be incomplete"
        send_failure_alert "Report generated but suspiciously small ($report_size bytes)" || true
        exit 1
    fi

    # Convert to HTML
    log "Converting report to HTML..."
    generate_html_email "$REPORT_FILE" "$HTML_FILE"

    # Send email
    log "Sending email to $EMAIL_TO..."
    if send_email "Morning Trading Prep - $TODAY" "$HTML_FILE"; then
        log "Email sent successfully to $EMAIL_TO"
    else
        log_error "Failed to send email"
        exit 2
    fi

    log "=== Morning Trading Prep Complete ==="
    exit 0
}

main "$@"
