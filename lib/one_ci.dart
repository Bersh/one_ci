import 'dart:io';

enum RepoType { github, gitlab }

const String githubCiString = '''
name: CI

on:
  push:
    branches: [ ":branch:" ]
  pull_request:
    branches: [ ":branch:" ]

  workflow_dispatch:

jobs:
  build:
    name: Create Build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: "12.x"
          cache: gradle
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.7.1"
          channel: 'stable'
          cache: true
      - name: Get dependencies
        run: flutter pub get
      - name: Build apk
        run: flutter build apk --debug

  test:
    name: Run flutter test
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: "12.x"
          cache: gradle
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.7.1"
          channel: 'stable'
          cache: true
      - name: Get dependencies
        run: flutter pub get
      - name: Run all tests
        run: flutter test
        ''';

const String gitlabCiString = '''
image: cirrusci/flutter:3.7.5

# Cache downloaded dependencies and plugins between builds.
cache:
  key: "\$CI_JOB_NAME"
  paths:
    - .pub-cache/global_packages

stages:
  - build
  - analyze
  - test

before_script:
  - export PATH="\$PATH":"\$HOME/.flutter-sdk/.pub-cache/bin"
  - flutter pub get
  - flutter pub global activate junitreport

build:
  stage: build
  script:
    - flutter build apk --debug
  tags:
    - shared
  only:
    - main
    - merge_requests

analyze:
  stage: analyze
  script:
    - flutter analyze || true
  tags:
    - shared
  only:
    - main
    - merge_requests

test:
  stage: test
  script:
    - flutter test --machine | dart pub global run junitreport:tojunit -o report.xml
  artifacts:
    when: always
    reports:
      junit:
        - report.xml
  tags:
    - shared
  only:
    - main
    - merge_requests
    ''';

extension RepoTypeExtension on RepoType {
  String get name {
    switch (this) {
      case RepoType.github:
        return 'github';
      case RepoType.gitlab:
        return 'gitlab';
    }
  }

  String getCiString(String branchName) {
    switch (this) {
      case RepoType.github:
        return githubCiString.replaceAll(':branch:', branchName);
      case RepoType.gitlab:
        return gitlabCiString.replaceAll(':branch:', branchName);
    }
  }

  File get ciFile {
    switch (this) {
      case RepoType.github:
        return File('.github/workflows/ci.yaml');
      case RepoType.gitlab:
        return File('.gitlab-ci.yml');
    }
  }
}
