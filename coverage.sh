#!/bin/bash
echo "Run flutter test with coverage"
flutter test --coverage

grep -vE "/presenter(/[^/]*)*/page/" coverage/lcov.info | grep -vE "/presenter(/[^/]*)*/widgets/" > coverage/lcov_filtered.info

echo "Generating HTML coverage report"
genhtml --ignore-errors unmapped coverage/lcov_filtered.info -o coverage/html

echo "Coverage report: file://$PWD/coverage/html/index.html"

