#!/bin/bash

echo ""
echo "───────────────────────────────────────────────────────"
echo "STEP 1: Getting Flutter dependencies"
echo "───────────────────────────────────────────────────────"
flutter pub get

echo ""
echo "───────────────────────────────────────────────────────"
echo "STEP 2: Running tests with coverage"
echo "───────────────────────────────────────────────────────"
flutter test --coverage

echo ""
echo "───────────────────────────────────────────────────────"
echo "STEP 3: Filtering out presenter/page and presenter/widgets"
echo "───────────────────────────────────────────────────────"
grep -vE "/presenter(/[^/]*)*/page/" coverage/lcov.info | grep -vE "/presenter(/[^/]*)*/widgets/" > coverage/lcov_filtered.info

echo ""
echo "───────────────────────────────────────────────────────"
echo "STEP 4: Generating HTML coverage report (optional)"
echo "───────────────────────────────────────────────────────"
genhtml --ignore-errors unmapped,unmapped coverage/lcov_filtered.info -o coverage/html

echo ""
echo "───────────────────────────────────────────────────────"
echo "STEP 5: Report path (open in browser if local)"
echo "───────────────────────────────────────────────────────"
echo "file://$PWD/coverage/html/index.html"
