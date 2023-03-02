library one_ci;

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

/// A Calculator.
class Github {
  static String getCiString(String branchName) {
    return githubCiString.replaceAll(':branch:', branchName);
  }
}

