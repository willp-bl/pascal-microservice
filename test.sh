#!/usr/bin/env bash

set -eu

ROOT_DIR="$(dirname "$0")"
cd "$ROOT_DIR"

# remove this to force a new clone
#rm -rf brookframework

echo "Compiling..."
./compile.sh > /dev/null 2>&1

export PORT=8080

echo "Starting app..."
./pascalmicroservice.exe > pascalmicroservice.log &
APP_PID=$!
sleep 1 # let the app settle down

function errfunc {
    echo "tests fail!"
}
trap errfunc ERR

function exitfunc {
    kill $APP_PID
}
trap exitfunc EXIT

echo "Testing..."
PASS=true
echo "test run at $(date)" > test.log

function _test {
    local _PATH="$1"
    local EXPECTED_STATUS_CODE="$2"
    local EXPECTED_TEXT="$3"
    local RET
    if [ ! -z "${4:-}" ]; then
        RET="$(curl -v -XPOST -d "$4" "http://localhost:$PORT$_PATH" 2>&1)"
    else
        RET="$(curl -v "http://localhost:$PORT$_PATH" 2>&1)"
    fi
    local PASS=true
    if [ "$(echo "$RET" | grep -c "< Status: $EXPECTED_STATUS_CODE")" -ne 1 ]; then
      echo "did not respond 200 OK:" >> test.log
      echo "$RET" >> test.log
      PASS=false
    fi
    if [ "$(echo "$RET" | grep -c "$EXPECTED_TEXT")" -ne 1 ]; then
      echo "did not respond \"$EXPECTED_TEXT\":" >> test.log
      echo "$RET" >> test.log
      PASS=false
    fi
    echo "pass: $PASS" >> test.log
    $PASS && printf "test: %-22s -> %-10s\\n" "$_PATH" "pass" || printf "test: %-22s -> %-10s\\n" "$_PATH" "fail"
    $PASS && printf "test: %-22s -> %-10s\\n" "$_PATH" "pass" >> test.log || printf "test: %-22s -> %-10s\\n" "$_PATH" "fail" >> test.log
    if [ "$PASS" != "true" ]; then return 1; fi
}

_test / 200 'welcome to paascal' || PASS=false
_test /hello 200 'Hello world!' || PASS=false
_test /json 200 '{ "message" : "hello world" }' || PASS=false
_test /factoral?fffffff=true 200 'fffffff=true' || PASS=false
_test /path/101 200 'variable1: 101' || PASS=false
_test /post/form 200 '<button' || PASS=false
_test /post/form 200 'foo' 'freetext=foo' || PASS=false
_test /nothingconfigured 404 'Page not found' || PASS=false

if [ "$PASS" != "true" ]; then exit 1; fi

# should also check the log

echo "test success!"
