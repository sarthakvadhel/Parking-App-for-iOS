# CI/CD Implementation Plan
## GitHub Actions + Fastlane for iOS Parking App

**Version:** 1.0  
**Date:** 2025-10-11  
**Target Platform:** iOS 15+

---

## Overview

This document provides a complete CI/CD setup for the Parking App using GitHub Actions and fastlane. The pipeline includes linting, testing, building, and automated TestFlight deployment.

---

## Architecture

```
┌─────────────────────────────────────────┐
│         GitHub Actions Workflow         │
├─────────────────────────────────────────┤
│                                         │
│  Push/PR → Lint → Test → Build         │
│             ↓      ↓      ↓             │
│          SwiftLint │   Security         │
│          SwiftFormat   Scan             │
│                     ↓                    │
│                  Coverage                │
│                     ↓                    │
│            Upload to Codecov            │
│                                         │
│  Main Branch Only:                      │
│    → Build Archive                      │
│    → Sign with Match                    │
│    → Upload to TestFlight               │
│    → Notify Slack/Teams                 │
└─────────────────────────────────────────┘
```

---

## Prerequisites

### 1. GitHub Secrets Setup

Navigate to: `Settings → Secrets and variables → Actions → New repository secret`

| Secret Name | Description | How to Obtain |
|-------------|-------------|---------------|
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID for API key | Same as above |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Base64 encoded .p8 key file | `cat AuthKey_XXXXX.p8 \| base64` |
| `MATCH_PASSWORD` | Password for certificates repo | Create strong password for fastlane match |
| `MATCH_GIT_BASIC_AUTHORIZATION` | GitHub token for match repo | `echo -n "username:token" \| base64` |
| `FIREBASE_CONFIG_DEV` | Dev Firebase config | Base64 encode GoogleService-Info.plist |
| `FIREBASE_CONFIG_PROD` | Prod Firebase config | Base64 encode GoogleService-Info.plist |
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications | [Slack API → Incoming Webhooks](https://api.slack.com/messaging/webhooks) |
| `CODECOV_TOKEN` | Token for code coverage | [Codecov.io](https://codecov.io/) |

### 2. App Store Connect API Key

```bash
# 1. Generate API Key in App Store Connect
# 2. Download the .p8 file
# 3. Base64 encode it
cat AuthKey_XXXXX.p8 | base64 | pbcopy

# 4. Add to GitHub Secrets
# 5. Store key ID and issuer ID as separate secrets
```

### 3. Fastlane Match Setup

```bash
# Install fastlane
sudo gem install fastlane

# Navigate to project
cd /path/to/ParkingApp

# Initialize fastlane
fastlane init

# Setup match (certificate management)
fastlane match init

# Generate certificates
fastlane match development
fastlane match appstore
```

---

## GitHub Actions Workflows

### Main Workflow: `.github/workflows/ios-ci.yml`

```yaml
name: iOS CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:

env:
  XCODE_VERSION: '15.2'
  DERIVED_DATA_PATH: 'DerivedData'
  SCHEME: 'ParkingApp'

jobs:
  lint:
    name: 🔍 Lint
    runs-on: macos-14
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install SwiftLint
        run: |
          brew install swiftlint

      - name: Run SwiftLint
        run: |
          swiftlint lint --reporter github-actions-logging --strict

      - name: Install SwiftFormat
        run: |
          brew install swiftformat

      - name: Check Swift Format
        run: |
          swiftformat --lint . --swiftversion 5.9

  security-scan:
    name: 🔐 Security Scan
    runs-on: macos-14
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Scan for secrets
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD

      - name: Check for sensitive files
        run: |
          if [ -f "ParkingApp/GoogleService-Info.plist" ]; then
            echo "❌ ERROR: GoogleService-Info.plist should not be committed"
            exit 1
          fi
          echo "✅ No sensitive files found"

  test:
    name: 🧪 Test
    runs-on: macos-14
    needs: [lint]
    strategy:
      matrix:
        destination:
          - 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2'
          - 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=17.2'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode
        run: |
          sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Cache SPM
        uses: actions/cache@v3
        with:
          path: |
            .build
            ~/Library/Developer/Xcode/DerivedData/**/SourcePackages
          key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
          restore-keys: |
            ${{ runner.os }}-spm-

      - name: Cache DerivedData
        uses: actions/cache@v3
        with:
          path: ${{ env.DERIVED_DATA_PATH }}
          key: ${{ runner.os }}-derived-data-${{ hashFiles('**/*.swift') }}
          restore-keys: |
            ${{ runner.os }}-derived-data-

      - name: Create Firebase Config (Dev)
        run: |
          echo "${{ secrets.FIREBASE_CONFIG_DEV }}" | base64 --decode > ParkingApp/GoogleService-Info.plist

      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme ${{ env.SCHEME }} \
            -destination "${{ matrix.destination }}" \
            -derivedDataPath ${{ env.DERIVED_DATA_PATH }} \
            -enableCodeCoverage YES \
            -resultBundlePath TestResults-${{ strategy.job-index }}.xcresult \
            | xcpretty

      - name: Generate Coverage Report
        if: matrix.destination == 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2'
        run: |
          xcrun xccov view --report --json TestResults-0.xcresult > coverage.json
          
          # Convert to lcov format for Codecov
          if command -v xcov-to-lcov &> /dev/null; then
            xcov-to-lcov coverage.json > coverage.lcov
          fi

      - name: Upload Coverage to Codecov
        if: matrix.destination == 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2'
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage.lcov
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: true

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results-${{ strategy.job-index }}
          path: TestResults-${{ strategy.job-index }}.xcresult
          retention-days: 30

  ui-test:
    name: 🎨 UI Tests
    runs-on: macos-14
    needs: [lint]
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app

      - name: Create Firebase Config
        run: |
          echo "${{ secrets.FIREBASE_CONFIG_DEV }}" | base64 --decode > ParkingApp/GoogleService-Info.plist

      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme "${SCHEME}UITests" \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.2' \
            -derivedDataPath ${{ env.DERIVED_DATA_PATH }} \
            -resultBundlePath UITestResults.xcresult \
            | xcpretty

      - name: Upload UI Test Screenshots
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: ui-test-failures
          path: UITestResults.xcresult

  build:
    name: 🏗️ Build
    runs-on: macos-14
    needs: [test, ui-test]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install Fastlane
        run: |
          gem install fastlane

      - name: Create Firebase Config (Prod)
        run: |
          echo "${{ secrets.FIREBASE_CONFIG_PROD }}" | base64 --decode > ParkingApp/GoogleService-Info.plist

      - name: Setup App Store Connect API Key
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "${{ secrets.APP_STORE_CONNECT_API_KEY_CONTENT }}" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}.p8

      - name: Increment Build Number
        run: |
          BUILD_NUMBER=${{ github.run_number }}
          /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" ParkingApp/Info.plist
          echo "Build number set to: $BUILD_NUMBER"

      - name: Build & Upload to TestFlight
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
        run: |
          fastlane beta \
            changelog:"$(git log -1 --pretty=%B)" \
            build_number:${{ github.run_number }}

      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: ParkingApp-${{ github.run_number }}.ipa
          path: "*.ipa"
          retention-days: 90

      - name: Notify Slack
        if: always()
        run: |
          STATUS="${{ job.status }}"
          COLOR="good"
          if [ "$STATUS" = "failure" ]; then
            COLOR="danger"
          fi
          
          curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
            -H 'Content-Type: application/json' \
            -d '{
              "attachments": [{
                "color": "'$COLOR'",
                "title": "iOS Build #${{ github.run_number }}",
                "text": "Status: '$STATUS'\nBranch: ${{ github.ref_name }}\nCommit: ${{ github.sha }}",
                "fields": [
                  {
                    "title": "Changelog",
                    "value": "'"$(git log -1 --pretty=%B)"'",
                    "short": false
                  }
                ]
              }]
            }'

  deploy-production:
    name: 🚀 Deploy to App Store
    runs-on: macos-14
    needs: [build]
    if: github.ref == 'refs/heads/main' && contains(github.event.head_commit.message, '[release]')
    environment:
      name: production
      url: https://apps.apple.com/app/parking-app/id123456789
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Fastlane
        run: gem install fastlane

      - name: Release to App Store
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
        run: |
          fastlane release
```

---

### Pull Request Workflow: `.github/workflows/pr-check.yml`

```yaml
name: PR Checks

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  danger:
    name: 🚨 Danger
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'

      - name: Install Danger
        run: gem install danger

      - name: Run Danger
        env:
          DANGER_GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: danger

  code-review:
    name: 📝 Automated Code Review
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check PR size
        run: |
          FILES_CHANGED=$(git diff --name-only origin/${{ github.base_ref }}...HEAD | wc -l)
          LINES_CHANGED=$(git diff --stat origin/${{ github.base_ref }}...HEAD | tail -1 | awk '{print $4}')
          
          echo "Files changed: $FILES_CHANGED"
          echo "Lines changed: $LINES_CHANGED"
          
          if [ $FILES_CHANGED -gt 50 ]; then
            echo "::warning::Large PR: $FILES_CHANGED files changed. Consider breaking into smaller PRs."
          fi

      - name: Check for TODO/FIXME
        run: |
          if git diff origin/${{ github.base_ref }}...HEAD | grep -E "TODO|FIXME|XXX|HACK"; then
            echo "::warning::Found TODO/FIXME comments in PR"
          fi
```

---

## Fastlane Configuration

### `fastlane/Fastfile`

```ruby
# fastlane/Fastfile

default_platform(:ios)

# Constants
SCHEME = "ParkingApp"
WORKSPACE = "ParkingApp.xcworkspace"
PROJECT = "ParkingApp.xcodeproj"
BUNDLE_ID = "com.parking.app"

platform :ios do
  
  before_all do
    setup_ci if ENV['CI']
  end

  desc "Run all tests"
  lane :test do
    run_tests(
      scheme: SCHEME,
      devices: ["iPhone 15 Pro", "iPhone SE (3rd generation)"],
      code_coverage: true,
      output_directory: "./fastlane/test_output",
      xcargs: "-skipPackagePluginValidation"
    )
  end

  desc "Run SwiftLint"
  lane :lint do
    swiftlint(
      mode: :lint,
      strict: true,
      reporter: "json",
      output_file: "./fastlane/swiftlint-results.json"
    )
  end

  desc "Build for testing"
  lane :build_for_testing do
    scan(
      scheme: SCHEME,
      build_for_testing: true,
      derived_data_path: "DerivedData"
    )
  end

  desc "Increment build number"
  lane :bump_build do |options|
    build_number = options[:build_number] || number_of_commits
    
    increment_build_number(
      build_number: build_number,
      xcodeproj: PROJECT
    )
    
    UI.success "Build number set to: #{build_number}"
  end

  desc "Match certificates - Development"
  lane :sync_dev_certs do
    match(
      type: "development",
      app_identifier: BUNDLE_ID,
      readonly: is_ci
    )
  end

  desc "Match certificates - App Store"
  lane :sync_appstore_certs do
    match(
      type: "appstore",
      app_identifier: BUNDLE_ID,
      readonly: is_ci
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do |options|
    # Ensure we have the latest certs
    sync_appstore_certs

    # Increment build number
    bump_build(build_number: options[:build_number])

    # Build the app
    build_app(
      scheme: SCHEME,
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          BUNDLE_ID => "match AppStore #{BUNDLE_ID}"
        }
      },
      output_directory: "./build",
      output_name: "ParkingApp.ipa",
      clean: true,
      xcargs: "-skipPackagePluginValidation"
    )

    # Upload to TestFlight
    upload_to_testflight(
      api_key_path: ENV['APP_STORE_CONNECT_API_KEY_PATH'] || "~/.appstoreconnect/private_keys/AuthKey_#{ENV['APP_STORE_CONNECT_API_KEY_ID']}.p8",
      skip_submission: true,
      skip_waiting_for_build_processing: true,
      changelog: options[:changelog] || "Bug fixes and improvements",
      distribute_external: true,
      groups: ["Beta Testers", "Internal Team"],
      notify_external_testers: true
    )

    # Clean up build artifacts
    clean_build_artifacts

    UI.success "Successfully uploaded to TestFlight! 🚀"
  end

  desc "Release to App Store"
  lane :release do
    # Ensure certs are up to date
    sync_appstore_certs

    # Capture screenshots
    capture_screenshots(
      scheme: "#{SCHEME}UITests",
      output_directory: "./fastlane/screenshots"
    )

    # Build
    build_app(
      scheme: SCHEME,
      export_method: "app-store",
      clean: true
    )

    # Upload metadata and screenshots
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      phased_release: true,
      force: true,
      submission_information: {
        add_id_info_uses_idfa: false,
        export_compliance_uses_encryption: false
      },
      release_notes: {
        "default" => File.read("./metadata/release_notes.txt"),
        "en-US" => File.read("./metadata/release_notes.txt")
      }
    )

    # Tag release
    add_git_tag(
      tag: "v#{get_version_number}/#{get_build_number}",
      message: "Release v#{get_version_number} (#{get_build_number})"
    )

    push_git_tags

    UI.success "App successfully submitted for review! 📱"
  end

  desc "Create screenshots"
  lane :screenshots do
    capture_screenshots(
      scheme: "#{SCHEME}UITests",
      output_directory: "./fastlane/screenshots",
      clear_previous_screenshots: true,
      override_status_bar: true,
      localize_simulator: true,
      devices: [
        "iPhone 15 Pro Max",
        "iPhone 15 Pro",
        "iPhone SE (3rd generation)",
        "iPad Pro (12.9-inch) (6th generation)"
      ],
      languages: ["en-US"]
    )
  end

  desc "Run performance tests"
  lane :performance do
    run_tests(
      scheme: "#{SCHEME}PerformanceTests",
      devices: ["iPhone 15 Pro"],
      xcargs: "-testPlan PerformanceTests"
    )
  end

  desc "Generate code coverage report"
  lane :coverage do
    run_tests(
      scheme: SCHEME,
      code_coverage: true
    )

    xcov(
      scheme: SCHEME,
      output_directory: "./fastlane/coverage",
      html_report: true,
      markdown_report: true,
      minimum_coverage_percentage: 70.0
    )
  end

  # Error handling
  error do |lane, exception, options|
    UI.error "Lane #{lane} failed with exception: #{exception}"
    
    # Notify on failure
    slack(
      message: "iOS Build Failed!",
      success: false,
      slack_url: ENV['SLACK_WEBHOOK_URL'],
      payload: {
        "Build Date" => Time.new.to_s,
        "Built by" => ENV['USER'] || "CI",
        "Error" => exception.to_s
      }
    ) if ENV['SLACK_WEBHOOK_URL']
  end

  after_all do |lane, options|
    # Notify on success
    slack(
      message: "iOS Build Succeeded!",
      success: true,
      slack_url: ENV['SLACK_WEBHOOK_URL'],
      payload: {
        "Build Date" => Time.new.to_s,
        "Built by" => ENV['USER'] || "CI"
      }
    ) if ENV['SLACK_WEBHOOK_URL'] && lane != :test
  end
end
```

---

### `fastlane/Matchfile`

```ruby
# fastlane/Matchfile

git_url("git@github.com:your-org/certificates.git")
storage_mode("git")

type("development") # development, adhoc, appstore, enterprise
app_identifier(["com.parking.app"])
username("your-apple-id@email.com")

# For Xcode 8 and up
# team_id("123ABC")

# Force match to use the legacy build API
force_for_new_devices(true)
```

---

### `fastlane/Appfile`

```ruby
# fastlane/Appfile

app_identifier("com.parking.app")
apple_id("your-apple-id@email.com")
team_id("123ABC")

# App Store Connect API
app_store_connect_api_key(
  key_id: ENV['APP_STORE_CONNECT_API_KEY_ID'],
  issuer_id: ENV['APP_STORE_CONNECT_ISSUER_ID'],
  key_filepath: "~/.appstoreconnect/private_keys/AuthKey_#{ENV['APP_STORE_CONNECT_API_KEY_ID']}.p8",
  in_house: false
)
```

---

## SwiftLint Configuration

### `.swiftlint.yml`

```yaml
# .swiftlint.yml

disabled_rules:
  - trailing_whitespace
  - todo

opt_in_rules:
  - array_init
  - closure_end_indentation
  - closure_spacing
  - contains_over_first_not_nil
  - empty_count
  - explicit_init
  - file_header
  - first_where
  - force_unwrapping
  - missing_docs
  - multiline_parameters
  - operator_usage_whitespace
  - overridden_super_call
  - private_outlet
  - redundant_nil_coalescing
  - sorted_imports
  - unneeded_parentheses_in_closure_argument

excluded:
  - Pods
  - DerivedData
  - .build
  - build
  - Carthage
  - fastlane

included:
  - ParkingApp

# Rules configuration
line_length:
  warning: 120
  error: 200
  ignores_function_declarations: true
  ignores_comments: true

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500

cyclomatic_complexity:
  warning: 15
  error: 25

identifier_name:
  min_length:
    warning: 2
    error: 1
  max_length:
    warning: 50
    error: 60
  excluded:
    - id
    - db
    - to
    - by

reporter: "xcode"
```

---

## Branch Protection Rules

Configure in: `Settings → Branches → Add rule`

### Main Branch
- ✅ Require pull request reviews before merging (1 approval)
- ✅ Require status checks to pass before merging:
  - `lint`
  - `test`
  - `security-scan`
- ✅ Require conversation resolution before merging
- ✅ Require signed commits
- ✅ Include administrators
- ✅ Restrict who can push to matching branches

### Develop Branch
- ✅ Require pull request reviews before merging (1 approval)
- ✅ Require status checks to pass:
  - `lint`
  - `test`
- ✅ Require conversation resolution

---

## Monitoring & Alerts

### Slack Notifications

```yaml
# .github/workflows/notify.yml
name: Slack Notifications

on:
  workflow_run:
    workflows: ["iOS CI/CD"]
    types: [completed]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Send notification
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
          fields: repo,message,commit,author,action,eventName,ref,workflow
```

### Email Notifications

Configure in GitHub: `Settings → Notifications → Email notifications`

---

## Performance Optimization

### Build Caching

```yaml
# Caching strategy in workflows
- uses: actions/cache@v3
  with:
    path: |
      ~/Library/Developer/Xcode/DerivedData
      ~/.build
    key: ${{ runner.os }}-xcode-${{ hashFiles('**/*.swift', '**/*.pbxproj') }}
    restore-keys: |
      ${{ runner.os }}-xcode-
```

### Parallel Testing

```ruby
# fastlane/Fastfile
lane :test_parallel do
  scan(
    scheme: SCHEME,
    parallel_testing: true,
    max_concurrent_simulators: 4
  )
end
```

---

## Troubleshooting

### Common Issues

1. **Certificate Mismatch**
```bash
# Reset certificates
fastlane match nuke development
fastlane match nuke distribution
fastlane match development
fastlane match appstore
```

2. **Build Number Conflicts**
```bash
# Fetch latest build number from App Store Connect
fastlane run latest_testflight_build_number app_identifier:"com.parking.app"
```

3. **Provisioning Profile Expired**
```bash
# Renew profiles
fastlane match development --force
fastlane match appstore --force
```

---

## Deployment Checklist

### Before First Deployment
- [ ] Setup App Store Connect API key
- [ ] Configure fastlane match
- [ ] Add all GitHub secrets
- [ ] Test workflow on feature branch
- [ ] Review App Store metadata
- [ ] Prepare screenshots

### Before Each Release
- [ ] Update version number
- [ ] Write release notes
- [ ] Run full test suite locally
- [ ] Verify TestFlight build
- [ ] Get stakeholder approval
- [ ] Submit for App Store review

---

## Metrics & SLOs

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Build time | < 15 minutes | TBD | ⏸️ |
| Test execution | < 10 minutes | TBD | ⏸️ |
| CI success rate | > 95% | TBD | ⏸️ |
| Deploy frequency | Daily (main branch) | TBD | ⏸️ |
| TestFlight processing | < 30 minutes | TBD | ⏸️ |

---

## Cost Optimization

### GitHub Actions Minutes
- macOS runners: **10x multiplier** (10 minutes = 100 billed minutes)
- Estimated monthly usage: ~3,000 minutes = 30,000 billed minutes
- Free tier: 2,000 minutes/month
- Overage cost: ~$0.08/minute = **$2,400/month** 😱

**Optimization Strategies:**
1. Cache aggressively (saves 5-10 minutes per build)
2. Run expensive jobs only on main branch
3. Parallelize when possible
4. Consider self-hosted runners for high volume

---

**Document Owner:** DevOps Team  
**Last Updated:** 2025-10-11  
**Next Review:** After first successful deployment
