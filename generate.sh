#!/bin/sh
# Regenerate the CRA conformity pack for capa_paymentguard.
#
# Every artifact under conformity/ is emitted by the Capa compiler from
# main.capa, so the pack is reproducible: an assessor can rerun this and
# diff the output against what ships in the repo.
set -e

mkdir -p conformity

capa --manifest   main.capa > conformity/manifest.json
capa --cyclonedx  main.capa > conformity/sbom.cyclonedx.json
capa --spdx       main.capa > conformity/sbom.spdx.json
capa --vex        main.capa > conformity/vex.cyclonedx.json
capa --provenance main.capa > conformity/provenance.slsa.json

echo "conformity pack regenerated under conformity/"
