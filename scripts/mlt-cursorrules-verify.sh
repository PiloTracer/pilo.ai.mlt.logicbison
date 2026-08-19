#!/usr/bin/env bash
# mlt-cursorrules-verify.sh — verify (optionally repair) a deployed target's
# .cursorrules against the CURRENT pilo.trainer.mlt source location.
#
# Read-only by default. --fix applies safe mechanical repairs (idempotent;
# preserves target customizations and filled REPLACE: tokens):
#   thin-client: re-sync TRAINER_MLT_SOURCE to the current source (in place,
#                all other lines untouched)
#   both:        fill open sister cells (REPLACE:AI_*_PATH) when the sister is
#                installed on disk; rewrite stale baked sister absolute paths
#                when the sister moved together with the source
#
# Checks (both layouts):
#   - .cursorrules present
#   - TRAINER_MLT_SOURCE filled + reachable + is a valid framework root
#   - fat-client: local .ai.mlt/ assets complete; mixed-state warning
#   - .work.mlt/ skeleton (dirs + PROFILE/HANDOFF/NEXT/UNKNOWNS)
#   - duplicate MLT sections (merged targets)
#   - alias collision: {HANDOFF}/{NEXT} bound to another framework without
#     namespaced {MLT_*} aliases
#   - REPLACE: tokens remaining (info)
#
# Usage:
#   bash scripts/mlt-cursorrules-verify.sh <target-root> [--fix] [--thin|--fat|--self]
#   MLT_SOURCE=/abs/path/.ai.mlt bash scripts/mlt-cursorrules-verify.sh <target-root>
#
# Flags accept the '--' prefix or bare form; '-' / '--' separators are ignored;
# the target path may appear in any position:
#   mlt-cursorrules-verify.sh /path fix   ≡   mlt-cursorrules-verify.sh /path --fix
#
# Exit: 0 = no FAIL findings · 1 = FAIL findings remain (after --fix when given)
#       2 = usage error. WARN/INFO findings never fail the run.

set -euo pipefail

# ── Argument normalization (bare verb ≡ --flag, path in any position) ──
FIX=0
LAYOUT=""
RAW_TARGET=""
for arg in "$@"; do
  [[ "$arg" == "-" || "$arg" == "--" ]] && continue
  tok="${arg#--}"
  case "$tok" in
    fix) FIX=1 ;;
    thin|fat|self) LAYOUT="$tok" ;;
    /*|./*|../*|~*|*/*|.)
      if [[ -z "$RAW_TARGET" ]]; then RAW_TARGET="$arg"
      else echo "ERROR: multiple target paths: '$RAW_TARGET' and '$arg'" >&2; exit 2; fi ;;
    *) echo "ERROR: unknown argument: $arg" >&2
       echo "Usage: $0 [--fix] [--thin|--fat|--self] <target-root> (path must contain '/'; use ./name for local dirs)" >&2
       exit 2 ;;
  esac
done
[[ -n "$RAW_TARGET" ]] || { echo "Usage: $0 [--fix] [--thin|--fat|--self] <target-root>" >&2; exit 2; }

# Source framework root: explicit override wins, else derive from script location.
if [[ -n "${MLT_SOURCE:-}" ]]; then
  MLT_ROOT="$(cd "$MLT_SOURCE" && pwd)"
else
  MLT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# Shared sister-framework discovery (family naming `pilo.ai.<fw>.logicbison` + legacy `.ai.<fw>`).
source "$MLT_ROOT/scripts/sister-discovery.sh"

if [[ "$RAW_TARGET" == "." || "$RAW_TARGET" == "$PWD" ]]; then
  DEST_ROOT="$(pwd)"
else
  DEST_ROOT="$(cd "$RAW_TARGET" 2>/dev/null && pwd)" || {
    echo "ERROR: target directory does not exist: $RAW_TARGET" >&2; exit 2; }
fi
CURS_DEST="${DEST_ROOT}/.cursorrules"

FAILS=0
fail() { echo "  [FAIL] $1"; FAILS=$((FAILS+1)); }
warn() { echo "  [warn] $1"; }
ok()   { echo "  [ok] $1"; }
note() { echo "  [info] $1"; }

get_source() {
  [[ -f "$CURS_DEST" ]] || { printf ''; return 0; }
  local s
  s="$(grep -E '^TRAINER_MLT_SOURCE=' "$CURS_DEST" 2>/dev/null | head -1 | cut -d= -f2- || true)"
  if [[ -z "$s" ]]; then
    s="$(grep -oE 'TRAINER_MLT_SOURCE=[^[:space:]`]+' "$CURS_DEST" 2>/dev/null | head -1 | cut -d= -f2- || true)"
  fi
  printf '%s' "$s"
}

# The self framework slot (source basename without the `.ai.` prefix, e.g.
# `.ai.mlt` → `mlt`): the registry's self row (`*this directory*`) and the
# target's own source pointer are not sister cells — skip them in fill/check loops.
SELF_SLOT="$(basename "$MLT_ROOT" | sed 's/^\.ai\.//')"

# Sister lookup: candidate names = family (<prefix>.<fw>) then legacy (.ai.<fw>);
# candidate parents = canonical source parent first, then the consumer's own
# parent / root (fat-client / co-located layouts).
find_sister() {
  local fw="$1"
  find_sister_dir "$MLT_ROOT" "$fw" "$MLT_ROOT/.." "$(dirname "$DEST_ROOT")" "$DEST_ROOT" || true
}

# Extract baked sister paths from the target .cursorrules (any candidate dir
# name — family or legacy; custom manual cells are left untouched).
baked_sister_paths() {
  local fw="$1" names_re
  # Escape every ERE metachar (not just dots) — source basenames may contain
  # any character; an unescaped `(` or `|` would corrupt the pattern.
  names_re="$(sister_names "$fw" "$MLT_ROOT" | sed 's/[.[\*^$()+?{|]/\\&/g' | paste -sd'|' -)"
  grep -oE '/[^ |]+/[^ |]+' "$CURS_DEST" 2>/dev/null \
    | grep -E "/(${names_re})$" | sort -u || true
}

# ── Layout detection (unless forced) ──────────────────────────────────
SRC_VALUE="$(get_source)"
if [[ -z "$LAYOUT" ]]; then
  if [[ -n "$SRC_VALUE" && "$SRC_VALUE" != "REPLACE_BASICSOURCE" ]]; then
    LAYOUT="thin"
  elif [[ -d "${DEST_ROOT}/.ai.mlt/skills" ]]; then
    LAYOUT="fat"
  elif [[ -f "${DEST_ROOT}/skills/README.md" && -f "${DEST_ROOT}/templates/cursorrules.template" && -d "${DEST_ROOT}/curricula" ]]; then
    LAYOUT="self"   # the target IS the framework checkout (mlt-deploy-repo clone)
  else
    LAYOUT="thin"   # no local skills → thin-client (or not yet configured)
  fi
fi
[[ "$LAYOUT" == "self" && "$FIX" -eq 1 ]] && { note "self-hosted target: no pointer to fix"; FIX=0; }

# ── --fix: mechanical repairs (before checks so verdict reflects them) ──
if [[ "$FIX" -eq 1 && -f "$CURS_DEST" ]]; then
  if [[ "$LAYOUT" == "thin" ]] && grep -q 'TRAINER_MLT_SOURCE=' "$CURS_DEST"; then
    MLT_ESC="${MLT_ROOT//\//\\/}"
    # Re-sync the source pointer in place (all other lines untouched).
    if [[ "$SRC_VALUE" != "$MLT_ROOT" ]]; then
      if [[ -n "$SRC_VALUE" && "$SRC_VALUE" != "REPLACE_BASICSOURCE" ]]; then
        perl -i -pe "s{TRAINER_MLT_SOURCE=\Q${SRC_VALUE}\E}{TRAINER_MLT_SOURCE=${MLT_ESC}}g" "$CURS_DEST"
      else
        perl -i -pe "s/TRAINER_MLT_SOURCE=[^\n]*/TRAINER_MLT_SOURCE=${MLT_ESC}/" "$CURS_DEST"
      fi
      echo "  [fix] TRAINER_MLT_SOURCE → $MLT_ROOT (was: ${SRC_VALUE:-<unset>})"
    fi
    # Re-point stale baked absolute references to the framework tree (merged
    # sections may carry absolutes from an earlier deploy).
    if [[ -n "$SRC_VALUE" && "$SRC_VALUE" != "$MLT_ROOT" && "$SRC_VALUE" != "REPLACE_BASICSOURCE" ]]; then
      before="$(mktemp)"; cp "$CURS_DEST" "$before"
      perl -i -pe "s{\Q${SRC_VALUE}\E/}{${MLT_ESC}/}g" "$CURS_DEST"
      cmp -s "$before" "$CURS_DEST" || echo "  [fix] re-pointed baked framework paths → $MLT_ROOT/"
      rm -f "$before"
    fi
  fi
  # Sister framework cells (both layouts): fill open REPLACE:AI_*_PATH tokens
  # when the sister is installed on disk; re-point stale baked absolute paths.
  for fw in $FRAMEWORK_SLOTS; do
    [[ "$fw" == "$SELF_SLOT" ]] && continue
    FWU="$(echo "$fw" | tr '[:lower:]' '[:upper:]')"
    token="REPLACE:AI_${FWU}_PATH"
    sister_dir="$(find_sister "$fw" || true)"
    if grep -q "$token" "$CURS_DEST"; then
      if [[ -n "$sister_dir" ]]; then
        fw_esc="${sister_dir//\//\\/}"
        perl -i -pe "s{${token} \\(default:? \\\`[^)]*\\)}{${fw_esc} (discovered at deploy time)}" "$CURS_DEST"
        echo "  [fix] sister .ai.${fw}: filled ${token} → ${sister_dir}"
      fi
      continue
    fi
    while IFS= read -r old; do
      [[ -z "$old" ]] && continue
      if [[ ! -d "$old" && -n "$sister_dir" && "$old" != "$sister_dir" ]]; then
        perl -i -pe "s{\Q${old}\E}{${sister_dir}}g" "$CURS_DEST"
        echo "  [fix] sister .ai.${fw}: re-pointed ${old} → ${sister_dir}"
      fi
    done < <(baked_sister_paths "$fw")
  done
fi

# ── Checks ─────────────────────────────────────────────────────────────
echo "mlt-cursorrules-verify → $DEST_ROOT (layout: ${LAYOUT}, source: $MLT_ROOT)"

if [[ ! -f "$CURS_DEST" ]]; then
  fail ".cursorrules: MISSING (run @mlt-deploy-basic / @mlt-deploy-files)"
  echo "mlt-cursorrules-verify: FAIL ($FAILS)"
  exit 1
fi
ok ".cursorrules: present"

# Thin-client: source pointer must be filled, reachable, and a valid framework root.
if [[ "$LAYOUT" == "thin" ]]; then
  SRC_NOW="$(get_source)"
  if ! grep -q 'TRAINER_MLT_SOURCE=' "$CURS_DEST"; then
    fail "TRAINER_MLT_SOURCE: line missing (self-hosted or fat-client contract? — no thin-client pointer to verify)"
  elif [[ -z "$SRC_NOW" || "$SRC_NOW" == "REPLACE_BASICSOURCE" ]]; then
    fail "TRAINER_MLT_SOURCE: unfilled (${SRC_NOW:-<empty>}) — run @mlt-deploy-basic update"
  elif [[ ! -d "$SRC_NOW" ]]; then
    fail "TRAINER_MLT_SOURCE: $SRC_NOW UNREACHABLE (source moved? run @mlt-deploy-basic update)"
  elif [[ ! -f "$SRC_NOW/skills/README.md" || ! -f "$SRC_NOW/.cursorrules" || ! -f "$SRC_NOW/START_HERE.md" ]]; then
    fail "TRAINER_MLT_SOURCE: $SRC_NOW is not a valid pilo.trainer.mlt root (missing skills/README.md, .cursorrules, or START_HERE.md)"
  else
    ok "TRAINER_MLT_SOURCE: $SRC_NOW (reachable, valid framework root)"
    [[ "$SRC_NOW" == "$MLT_ROOT" ]] || note "TRAINER_MLT_SOURCE differs from this source ($MLT_ROOT) — target tracks another source"
  fi
elif [[ "$LAYOUT" == "self" ]]; then
  # Self-hosted: the target IS the framework checkout (mlt-deploy-repo clone).
  SELF_OK=1
  for p in skills/README.md curricula standards references drills templates scripts START_HERE.md PROCESS_ROUTER.md .cursorrules; do
    if [[ ! -e "${DEST_ROOT}/$p" ]]; then
      fail "framework asset missing: $p (incomplete clone — re-run @mlt-deploy-repo)"
      SELF_OK=0
    fi
  done
  [[ "$SELF_OK" -eq 1 ]] && ok "framework checkout: complete (self-hosted)"
  if [[ -z "$SRC_VALUE" || "$SRC_VALUE" == "REPLACE_BASICSOURCE" ]]; then
    ok "TRAINER_MLT_SOURCE: unset token (correct for self-hosted — paths resolve locally)"
  elif [[ -d "$SRC_VALUE" ]]; then
    note "TRAINER_MLT_SOURCE: $SRC_VALUE (reachable — self-hosted usually leaves it unset)"
  else
    fail "TRAINER_MLT_SOURCE: $SRC_VALUE UNREACHABLE"
  fi
  note "deep framework checks: run scripts/framework-verify.sh"
else
  # Fat-client: vendored copy must be intact.
  FAT_OK=1
  for p in .ai.mlt/skills .ai.mlt/curricula .ai.mlt/standards .ai.mlt/references .ai.mlt/drills .ai.mlt/templates .ai.mlt/scripts .ai.mlt/START_HERE.md .ai.mlt/PROCESS_ROUTER.md; do
    if [[ ! -e "${DEST_ROOT}/$p" ]]; then
      fail "fat-client asset missing: $p (re-run @mlt-deploy-files)"
      FAT_OK=0
    fi
  done
  [[ "$FAT_OK" -eq 1 ]] && ok "local .ai.mlt/: complete (fat-client)"
  if [[ -n "$SRC_VALUE" && "$SRC_VALUE" != "REPLACE_BASICSOURCE" ]]; then
    warn "mixed state: TRAINER_MLT_SOURCE set AND local .ai.mlt/ present (fat-client resolves first)"
  fi
fi

# Duplicate MLT sections (merged targets must carry exactly one pointer).
if [[ -f "$CURS_DEST" ]]; then
  ptr_count="$(grep -c 'TRAINER_MLT_SOURCE=' "$CURS_DEST" 2>/dev/null || true)"
  if [[ "${ptr_count:-0}" -gt 1 ]]; then
    fail "duplicate MLT sections: TRAINER_MLT_SOURCE appears ${ptr_count}× (merge must be idempotent — remove duplicates)"
  else
    ok "MLT section: single (no duplication)"
  fi
fi

# Alias collision: another framework binds {HANDOFF}/{NEXT} (e.g. Agent OS
# .work/) and the MLT section never defines namespaced {MLT_*} aliases.
if grep -qE '\{HANDOFF\}[^/]*`?\.work/' "$CURS_DEST" || grep -qE '\.work/context/HANDOFF\.md' "$CURS_DEST"; then
  if grep -q 'TRAINER_MLT_SOURCE' "$CURS_DEST" && ! grep -q 'MLT_HANDOFF' "$CURS_DEST"; then
    warn "alias collision: {HANDOFF}/{NEXT} bound to another framework but no {MLT_HANDOFF}/{MLT_NEXT} aliases defined (see mlt-deploy-basic Merge procedure step 3)"
  fi
fi

# .work.mlt/ learner-memory skeleton.
SKEL_OK=1
for d in context plans programs sessions sources labs tutorials drills exports; do
  if [[ ! -d "${DEST_ROOT}/.work.mlt/$d" ]]; then
    fail ".work.mlt/$d/: missing (re-run @mlt-deploy-basic or templates/bootstrap.sh)"
    SKEL_OK=0
  fi
done
for f in context/PROFILE.md context/HANDOFF.md plans/NEXT.md plans/UNKNOWNS.md; do
  if [[ ! -f "${DEST_ROOT}/.work.mlt/$f" ]]; then
    fail ".work.mlt/$f: missing"
    SKEL_OK=0
  fi
done
[[ "$SKEL_OK" -eq 1 ]] && ok ".work.mlt/ skeleton: complete"

# Sister framework cells (both layouts) — every non-self slot must resolve.
for fw in $FRAMEWORK_SLOTS; do
  if [[ "$fw" == "$SELF_SLOT" ]]; then
    note ".ai.${fw}: self (this framework) — no sister cell to verify"
    continue
  fi
  FWU="$(echo "$fw" | tr '[:lower:]' '[:upper:]')"
  token="REPLACE:AI_${FWU}_PATH"
  if grep -q "$token" "$CURS_DEST"; then
    sister_dir="$(find_sister "$fw" || true)"
    if [[ -n "$sister_dir" ]]; then
      warn ".ai.${fw}: installed at ${sister_dir} but cell unfilled (${token}) — run deploy update"
    else
      checked="$(sister_names "$fw" "$MLT_ROOT" | paste -sd' ' -)"
      note ".ai.${fw}: not installed (checked ${checked} next to source + target; runtime auto-discover reports degraded — for other dir names, fill the cell manually)"
    fi
    continue
  fi
  baked="$(baked_sister_paths "$fw")"
  if [[ -z "$baked" ]]; then
    note ".ai.${fw}: custom cell value (non-standard — verify manually)"
    continue
  fi
  while IFS= read -r b; do
    [[ -z "$b" ]] && continue
    if [[ -d "$b" && -f "${b}/skills/README.md" ]]; then
      ok ".ai.${fw} → ${b} (reachable)"
    else
      fail ".ai.${fw} → ${b} STALE (not a valid framework dir — run deploy update)"
    fi
  done <<< "$baked"
done

replace_count="$(grep -c 'REPLACE:' "$CURS_DEST" 2>/dev/null || true)"
note "REPLACE: tokens remaining: ${replace_count:-0} (operator fills project/learner tokens; TRAINER_MLT_SOURCE excluded)"

echo "mlt-cursorrules-verify: $([ "$FAILS" -eq 0 ] && echo PASS || echo "FAIL ($FAILS)")"
exit "$([ "$FAILS" -eq 0 ] && echo 0 || echo 1)"
