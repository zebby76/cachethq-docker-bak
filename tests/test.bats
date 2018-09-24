#!/usr/bin/env bats
load test_helpers
load docker_helpers
load "lib/batslib"
load "lib/output"

export CACHET_VERSION=${CACHET_VERSION:-2.3.15}

@test "[$TEST_FILE] Starting CachetHQ Docker images build" {
  command docker-compose build --no-cache php web queue_worker
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

@test "[$TEST_FILE] Cleanup test containers and orphaned volumes" {
  #command docker-compose down --volumes
}
