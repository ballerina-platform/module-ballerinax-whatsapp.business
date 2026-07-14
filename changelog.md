# Change Log

This file contains all the notable changes done to the Ballerina WhatsApp Business Cloud connector
through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- Initial release of the WhatsApp Business Cloud connector: a `Client` for sending messages,
  templates, and media (upload/retrieve/delete), and a webhook `Listener` for all ten WhatsApp
  Business Cloud webhook event types, with built-in `X-Hub-Signature-256` (HMAC-SHA256) webhook
  signature verification.
