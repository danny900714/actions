# Check Upstream Release

A GitHub action to check whether the upstream repository has a newer release than the current one.

> [!WARNING]
> This action only compares SemVer version core (MAJOR.MINOR.PATCH) to determine whether there's a new release.

## Usage

Specify the upstream reposiotry to watch for new releases.
If there's one, the action set the `new-upstream-version` output to the tag name of the new release.

```yaml
name: Check upstream release

on:
  schedule:
    - cron: 0 * * * *

permissions: {}

jobs:
  check-upstream-release:
    name: Check upstream release
    runs-on: ubuntu-latest

    steps:
      - name: Check upstream release
        id: check-upstream-release
        uses: danny900714/actions/check-upstream-release@main
        with:
          upstream-repository: ajayyy/SponsorBlock
      - name: Print if there's a new release
        if: ${{ steps.check-upstream-release.new-upstream-version != '' }}
        env:
          NEW_VERSION: ${{ steps.check-upstream-release.new-upstream-version }}
        run: echo $NEW_VERSION
```

## Customizing

### Inputs

The following inputs can be used as `step.with` keys:

| Name                         | Type   | Required | Description                                                                                                                                                                                                            |
| ---------------------------- | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| upstream-repository          | string | true     | The upstream repository                                                                                                                                                                                                |
| current-repository           | string | false    | The current repository.<br/>Default: `${{ github.repository }}`                                                                                                                                                               |
| semver-version-core-regex    | string | false    | The regex expression used to match the semver version core (MAJOR.MINOR.PATCH) from the relase tag name.<br/>Default: `(0\|[1-9][0-9]*)\.(0\|[1-9][0-9]*)\.(0\|[1-9][0-9]*)`                                           |
| if-current-release-not-found | string | false    | What to do if the current release is not found.<br/>Available options:<br/> lowest-version: use "0.0.0" as the current release version<br/> error: fail the action with an error message<br/>Default: `lowest-version` |
| token                        | string | false    | The GitHub token used to make authenticated API requests.<br/>Default: `${{ github.token }}`                                                                                                                                  |

### Outputs

The following outputs can be accessed via `${{ steps.<step-id>.outputs }}`:

| Name                 | Type   | Description                                                                                                                               |
| -------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| new-upstream-version | string | If the upstream repository has a newer release than the current one, this output parameter is populated with tag name of the new release. |
