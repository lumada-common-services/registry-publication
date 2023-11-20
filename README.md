# registry-publication
Generic github action to publish artifacts to Artifactory.

Usage example:
```
- name: Run publication to registry
  id: registry-publication-action
  continue-on-error: false
  uses: lumada-common-services/registry-publication@stable  #The stable tag always points to the latest changes
  with:
    ARTIFACTS_CONFIG_FILE: ".github/artifacts.yaml"
    ARTIFACTORY_APIKEY:    ${{ secrets.VC_ART_API_KEY }}
    ARTIFACTORY_USER:      ${{ secrets.VC_ART_USER }}
    BUILD_NUMBER:          ${{ github.run_number }}
    BUILD_NAME:            ${{ github.job }}
    BUILD_VERSION:         "0.0.1"
    WORKSPACE:             ${{ github.workspace }}
    BUILD_URL:             ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}
```

See all available tags [here](../../tags)

A small test smoke github workflow is available at [.github/workflows/smoke-tester.yaml](.github/workflows/smoke-tester.yml)
