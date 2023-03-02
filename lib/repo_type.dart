import 'dart:io';

import 'package:flutter/foundation.dart';

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

variables:

# Cache downloaded dependencies and plugins between builds.
cache:
  key: "\$CI_JOB_NAME"'
  paths:
    - .pub-cache/global_packages

stages:
  - build
  - analyze_and_test

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
    - :branch:
    - merge_requests

analyze_and_test:
  stage: analyze_and_test
  script:
    - flutter analyze
    - flutter test --machine | tojunit -o report.xml
  artifacts:
    when: always
    reports:
      junit:
        - report.xml
  tags:
    - shared
  only:
    - :branch:
    - merge_requests
    ''';

extension RepoTypeExtension on RepoType {
  String get name => describeEnum(this);

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
        return File('gitlab-ci.yaml');
    }
  }
}
