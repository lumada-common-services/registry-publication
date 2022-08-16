# registry-publication
Generic github action to publish artifacts (So far, container images and helm charts) to Artifactory.

Usage example:
```
- name: Run publication to registry
  id: registry-publication-action
  continue-on-error: false
  uses: ./
  with:
    IMAGES: |
      golden-vc-docker.repo.orl.eng.hitachivantara.com/busybox
      golden-vc-docker.repo.orl.eng.hitachivantara.com/hello-world
    HELM_CHARTS: |
      ./.github/resources/my-chart-1-0.0.1.tgz
      ./.github/resources/my-chart-2-0.0.1.tgz
      ./.github/resources/my-chart-3-0.0.1.tgz
    ARTIFACTORY_URL:         "https://repo.orl.eng.hitachivantara.com/artifactory/"
    ARTIFACTORY_APIKEY:      ${{ secrets.VC_ART_API_KEY }}
    ARTIFACTORY_USER:        ${{ secrets.VC_ART_USER }}
    ARTIFACTORY_HELM_REPO:   "temp-helm"
    ARTIFACTORY_DOCKER_REPO: "golden-vc-docker"
    BUILD_NUMBER:            ${{ github.run_number }}
    BUILD_NAME:              ${{ github.job }}
    WORKSPACE:               ${{ github.workspace }}
```

A small test smoke github workflow is available at [.github/workflows/smoke-tester.yaml](.github/workflows/smoke-tester.yml)
