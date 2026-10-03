#!/bin/sh
# Regenerate the CRA conformity pack for capa_paymentguard.
#
# Every artifact under conformity/ is emitted by the Capa compiler from
# main.capa. The compiler's tests pin byte-identical output for repeated
# runs of the same program; rerunning this script and diffing is a check
# to run, not a guarantee.
#
# RUN IT WITH THE COMPILER capa.toml DECLARES, currently 1.18.1. Every
# artefact carries a `capa_version` field and later releases add fields
# the emitters did not have before, so the output differs between
# COMPILER VERSIONS: regenerating on 1.19.0 moves all
# five files. If you bump the floor, regenerate and commit the pack in
# the same commit.
#
# Determinism comes from SOURCE_DATE_EPOCH (the reproducible-builds.org
# convention). The compiler's --cyclonedx / --spdx / --vex / --provenance
# emitters stamp their build time from this instant instead of the wall
# clock, so the timestamp fields (timestamp / created / annotationDate /
# startedOn / finishedOn) are pinned along with everything else.
#
# The epoch is a FIXED value versioned in conformity/SOURCE_DATE_EPOCH,
# NOT derived from the commit/HEAD time. That matters: the pack is
# generated and committed in one go, so deriving the epoch from HEAD
# would be circular. An assessor who checks out the pack's commit would
# see a different HEAD time than the one used to build it, and the diff
# would fail. A constant in the repo makes the build independent of when
# or where it runs.
#
# To bump the epoch for a new release, derive it from a chosen UTC date
# rather than hand-typing a number (which risks a wrong value):
#
#     date -u -d 2027-01-01 +%s > conformity/SOURCE_DATE_EPOCH   # GNU date
#     # BSD/macOS: date -u -j -f %Y-%m-%d 2027-01-01 +%s
#
# then rerun this script and commit the regenerated pack in the same
# commit.
set -e

# Strip any stray carriage return so the value is a clean decimal. The
# compiler's SOURCE_DATE_EPOCH parser actually TOLERATES a trailing CR
# (a value with \r still reads the correct instant), so this is defence
# in depth to keep the epoch file clean, not because the parser rejects
# it. With the eol=lf pin in .gitattributes a CRLF checkout cannot reach
# this file anyway.
SOURCE_DATE_EPOCH="$(tr -d '\r' < conformity/SOURCE_DATE_EPOCH)"
export SOURCE_DATE_EPOCH

mkdir -p conformity

capa --manifest   main.capa > conformity/manifest.json
capa --cyclonedx  main.capa > conformity/sbom.cyclonedx.json
capa --spdx       main.capa > conformity/sbom.spdx.json
capa --vex        main.capa > conformity/vex.cyclonedx.json
capa --provenance main.capa > conformity/provenance.slsa.json

echo "conformity pack regenerated under conformity/ (SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH)"
