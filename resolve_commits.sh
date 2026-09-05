# Resolves POKEEMERALD_COMMIT_HASH/AGBCC_COMMIT_HASH to each repo's latest commit, unless
# already set (e.g. a caller pinning a specific commit, or build_all.sh sharing one resolved
# commit across several variant builds). Meant to be sourced (". ./resolve_commits.sh"), not
# executed directly.
#
# A resolution failure (e.g. no network) only warns rather than aborting: podman build still
# runs, and the Containerfile's own fallback lets an already-cached build layer succeed fully
# offline, only actually needing network if that layer isn't cached yet.

# Use "${VAR+set}" (is it set at all?), not "${VAR:-...}" (is it set to something non-empty?),
# to decide whether to resolve. This matters when a resolution attempt already failed upstream
# (e.g. build_all.sh's own git ls-remote came back empty): that failure is still an exported,
# set value, and must be honored as-is rather than retried here -- otherwise a flaky network can
# make build_all.sh's 4 variant builds each independently retry and land on different results,
# defeating the one-resolution-shared-by-all guarantee.
if [ -z "${POKEEMERALD_COMMIT_HASH+set}" ]; then
    POKEEMERALD_COMMIT_HASH=$(git ls-remote https://github.com/pret/pokeemerald HEAD 2>/dev/null | cut -f1)
fi
if [ -z "${AGBCC_COMMIT_HASH+set}" ]; then
    AGBCC_COMMIT_HASH=$(git ls-remote https://github.com/pret/agbcc HEAD 2>/dev/null | cut -f1)
fi

if [ -z "$POKEEMERALD_COMMIT_HASH" ]; then
    echo "Warning: could not resolve the latest pokeemerald commit (offline?); build will fall back to a cached layer if one exists." >&2
fi
if [ -z "$AGBCC_COMMIT_HASH" ]; then
    echo "Warning: could not resolve the latest agbcc commit (offline?); build will fall back to a cached layer if one exists." >&2
fi
