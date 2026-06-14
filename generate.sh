#!/bin/sh
# Regenerate the CRA conformity pack for capa_paymentguard.
#
# Every artifact under conformity/ is emitted by the Capa compiler from
# main.capa, so the pack is byte-for-byte reproducible: an assessor can
# rerun this script and diff its output against what ships in the repo
# and get ZERO differences, not just "stable modulo timestamps".
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
# or where it runs. Bump conformity/SOURCE_DATE_EPOCH by hand per release.
set -e

# Strip any stray carriage return (a CRLF checkout on Windows) so the
# value is a clean decimal the compiler's strict parser accepts.
SOURCE_DATE_EPOCH="$(tr -d '\r' < conformity/SOURCE_DATE_EPOCH)"
export SOURCE_DATE_EPOCH

mkdir -p conformity

capa --manifest   main.capa > conformity/manifest.json
capa --cyclonedx  main.capa > conformity/sbom.cyclonedx.json
capa --spdx       main.capa > conformity/sbom.spdx.json
capa --vex        main.capa > conformity/vex.cyclonedx.json
capa --provenance main.capa > conformity/provenance.slsa.json

echo "conformity pack regenerated under conformity/ (SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH)"
