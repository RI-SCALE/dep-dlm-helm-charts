# dep-dlm-helm-charts

Helm charts for the DEP DLM services that run in both
[dep-dlm-testbed](https://github.com/RI-SCALE/dep-dlm-testbed) and
[dep-dlm-deployment](https://github.com/RI-SCALE/dep-dlm-deployment). Both pull
the same released chart versions, so what passes in the testbed is what gets
deployed.

Developed within RI-SCALE WP2 (DEP data lifecycle management).

## Charts

| Chart | Deploys | Image |
|---|---|---|
| `fts` | FTS3 server, optional MySQL (`ftsdb`) | [dep-dlm-containers](https://github.com/RI-SCALE/dep-dlm-containers) `fts` |
| `opa` | Open Policy Agent for Rucio's permission checks | `openpolicyagent/opa` |
| `observability` | SQL exporters for FTS and Rucio, alert and SLO rules (`PrometheusRule`), Grafana dashboard | `burningalchemist/sql_exporter` |

Published as `oci://ghcr.io/ri-scale/charts/dep-dlm/<chart>`.

Charts used only for testing (Keycloak, XRootD, teapot, rucio-client) stay in
the testbed. The Rucio server and daemon charts come from the upstream fork for
now.

## Developing

Needs Helm, kubeconform, Make and pre-commit; the devcontainer has all four.

```bash
make hooks   # install the pre-commit hook
make check   # pre-commit on all files
make lint    # helm lint --strict and kubeconform, defaults and ci/ values
make help    # all targets
```

Or with Helm directly:

```bash
helm lint --strict charts/fts
```

## Releasing

Pull requests and pushes to `main` only lint. A `vX.Y.Z` tag packages every
chart as version `X.Y.Z`, pushes it to GHCR with build provenance and creates
a GitHub release.

```bash
git tag v0.1.0 && git push origin v0.1.0
```

| Git tag | Chart version |
|---|---|
| `v0.1.0` | `0.1.0` (all charts) |

Charts are versioned together; a release can contain unchanged charts.
The `version` in each `Chart.yaml` is replaced by the tag at release time.

Verify a chart:

```bash
gh attestation verify oci://ghcr.io/ri-scale/charts/dep-dlm/fts:0.1.0 --owner RI-SCALE
```

## Using a new chart

1. Release a new version here.
2. Bump `version` for the chart in the testbed umbrella `Chart.yaml` and run
   the end-to-end tests.
3. Bump the same version in `dep-dlm-deployment` and add an entry to its
   `PROMOTION.md`.

A release that fails in the testbed is replaced by the next patch version.