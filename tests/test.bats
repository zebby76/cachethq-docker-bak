#!/usr/bin/env bats
load test_helpers
load docker_helpers
load "lib/batslib"
load "lib/output"

DEFAULT_VCS_REF=`git rev-parse --short HEAD`
DEFAULT_BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

export CACHET_VERSION=${CACHET_VERSION:-2.3.15}
export VCS_REF=${VCS_REF:-$DEFAULT_VCS_REF}
export BUILD_DATE=${VCS_REF:-$DEFAULT_BUILD_DATE}

@test "[$TEST_FILE] Starting CachetHQ Docker images build" {
  command docker-compose build --no-cache php web queue_worker
}

@test "[$TEST_FILE] Check for CachetHQ Web Container non existing command" {
  run docker run --rm docker.io/zebby76/cachet-web:latest not-exist
  assert_equal $status 127
}

@test "[$TEST_FILE] Check for CachetHQ Web Container usage command" {
  run docker run --rm docker.io/zebby76/cachet-web:latest usage
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Web Container apk-list command" {
  run docker run --rm docker.io/zebby76/cachet-web:latest apk-list
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ PHP-FPM Container non existing command" {
  run docker run --rm docker.io/zebby76/cachet-php:latest not-exist
  assert_equal $status 127
}

@test "[$TEST_FILE] Check for CachetHQ PHP-FPM Container usage command" {
  run docker run --rm docker.io/zebby76/cachet-php:latest usage
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ PHP-FPM Container apk-list command" {
  run docker run --rm docker.io/zebby76/cachet-php:latest apk-list
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ PHP-FPM Container generate-cachet-appkey command" {
  run docker run --rm docker.io/zebby76/cachet-php:latest generate-cachet-appkey
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Queue-Worker Container non existing command" {
  run docker run --rm docker.io/zebby76/cachet-queue-worker:latest not-exist
  assert_equal $status 127
}

@test "[$TEST_FILE] Check for CachetHQ Queue-Worker Container usage command" {
  run docker run --rm docker.io/zebby76/cachet-queue-worker:latest usage
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Queue-Worker Container apk-list command" {
  run docker run --rm docker.io/zebby76/cachet-queue-worker:latest apk-list
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Queue-Worker Container generate-cachet-appkey command" {
  run docker run --rm docker.io/zebby76/cachet-queue-worker:latest generate-cachet-appkey
  assert_equal $status 0
}

@test "[$TEST_FILE] Starting CachetHQ services (db, webserver, php-fpm, queue-worker)" {
  command docker-compose up -d
}

@test "[$TEST_FILE] Check for CachetHQ PostgreSQL database startup message in container log" {
  docker_wait_for_log cachet-pgsql 120 "LOG:  database system is ready to accept connections."
}

@test "[$TEST_FILE] Check for CachetHQ PHP-FPM startup init message in container log" {
  docker_wait_for_log cachet-php 15 "Starting Cachet! ..."
}

@test "[$TEST_FILE] Check for CachetHQ PHP-FPM startup message in container log" {
  docker_wait_for_log cachet-php 15 "fpm is running"
}

@test "[$TEST_FILE] Check for CachetHQ QUEUE-WORKER startup message in container log" {
  docker_wait_for_log cachet-queue-worker 15 "Starting Cachet Queue Worker"
}

@test "[$TEST_FILE] Check for CachetHQ setup page response code 200" {
  retry 12 5 curl_container cachet-web :8080/setup -s -w %{http_code} -o /dev/null
  assert_output -l 0 $'200'
}

@test "[$TEST_FILE] Check for CachetHQ Webserver setup request in container log" {
  docker_wait_for_log cachet-web 15 "\"GET /setup HTTP/1.1\" .* .* \"-\" \"curl.*\" \"-\""
}

@test "[$TEST_FILE] Build Cachet Monitoring Script Docker image" {
  docker_build ${BUILD_DATE} ${VCS_REF} ${CACHET_VERSION} docker.io/zebby76/cachet-monitoring-scripts latest box-monitoring-scripts/.
}

@test "[$TEST_FILE] Check for CachetHQ Monitoring-Scripts non existing command" {
  run docker run --rm docker.io/zebby76/cachet-monitoring-scripts:latest not-exist
  assert_equal $status 127
}

@test "[$TEST_FILE] Check for CachetHQ Monitoring-Scripts usage command" {
  run docker run --rm docker.io/zebby76/cachet-monitoring-scripts:latest usage
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Monitoring-Scripts apk-list command" {
  run docker run --rm docker.io/zebby76/cachet-monitoring-scripts:latest apk-list
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Monitoring-Scripts pip-list command" {
  run docker run --rm docker.io/zebby76/cachet-monitoring-scripts:latest pip-list
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Monitoring-Scripts foglightXml2cachethq command" {
  skip
  run docker run --rm docker.io/zebby76/cachet-monitoring-scripts:latest foglightXml2cachethq
  assert_equal $status 0
}

@test "[$TEST_FILE] Check for CachetHQ Monitoring-Scripts cachethqMonitor command" {
  skip
  run docker run --rm docker.io/zebby76/cachet-monitoring-scripts:latest cachethqMonitor
  assert_equal $status 0
}

@test "[$TEST_FILE] Cleanup test containers and orphaned volumes" {
  command docker-compose down --volumes
}
