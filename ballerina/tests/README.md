# Tests

This directory contains the package tests for the WhatsApp Business Cloud connector.

- `test.bal` — verifies the `X-Hub-Signature-256` HMAC-SHA256 webhook signature verification
  (valid / tampered / wrong-secret cases) and the connector client initialization.

## Running the tests

```bash
cd ballerina
bal test
```

Adding live API tests: create a `Config.toml` with `accessToken`, `phoneNumberId`, and
`recipientNumber`, and gate the tests with a test group so they are skipped by default in CI.
