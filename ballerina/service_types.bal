// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

# The service type a consumer implements to handle WhatsApp Business Cloud webhook events. Attach
# an implementation to a `Listener` to receive notifications.
#
# There are ten possible handlers, one per webhook field the WhatsApp Business Cloud webhook
# subscription can select. Unlike most Ballerina service types, none of them are required —
# declare only the ones you care about; a field whose handler you did not declare (or a field
# outside this closed set, e.g. `account_alerts`, `group_lifecycle_update`) is logged and dropped
# rather than delivered anywhere.
#
# An eleventh, optional handler, `onError`, does not correspond to a webhook field. It is invoked
# whenever one of the ten handlers above returns an `error` while being dispatched — the
# notification has already been acknowledged to Meta by that point, so this is the only way to
# react to a handler failure other than logging (which always happens regardless of whether
# `onError` is declared).
#
# A compiler plugin validates every remote function you do declare on a `WhatsAppService`: its
# name must be one of the eleven below, its parameter must match the documented event type, and it
# must return `error?`. Anything else is a compile-time error.
#
# - `remote function onMessages(MessagesNotificationEvent event) returns error?` — Invoked once
#   per `messages` webhook notification: either a batch of inbound messages or a batch of status
#   updates. Meta always sends these as two mutually exclusive shapes under this one field, never
#   both together; narrow with `event is MessagesEvent` / `event is MessageStatusEvent`.
# - `remote function onAccountReviewUpdate(AccountReviewUpdateEvent event) returns error?` —
#   Invoked when a WhatsApp Business Account's review decision changes.
# - `remote function onAccountUpdate(AccountUpdateEvent event) returns error?` — Invoked on
#   account-lifecycle and compliance changes (verification, violations, partner changes,
#   pricing-tier updates, restrictions, disconnection).
# - `remote function onBusinessCapabilityUpdate(BusinessCapabilityUpdateEvent event) returns error?`
#   — Invoked when a WABA's messaging or phone-number capability limits change.
# - `remote function onMessageTemplateQualityUpdate(MessageTemplateQualityUpdateEvent event) returns error?`
#   — Invoked when a message template's quality score changes.
# - `remote function onMessageTemplateStatusUpdate(MessageTemplateStatusUpdateEvent event) returns error?`
#   — Invoked when a message template's status changes (approved, rejected, disabled, ...).
# - `remote function onPhoneNumberNameUpdate(PhoneNumberNameUpdateEvent event) returns error?` —
#   Invoked when a business phone number's display-name review outcome is available.
# - `remote function onPhoneNumberQualityUpdate(PhoneNumberQualityUpdateEvent event) returns error?`
#   — Invoked when a business phone number's messaging throughput/quality tier changes.
# - `remote function onSecurity(SecurityEvent event) returns error?` — Invoked on
#   two-step-verification PIN changes and reset requests for a business phone number.
# - `remote function onTemplateCategoryUpdate(TemplateCategoryUpdateEvent event) returns error?` —
#   Invoked when a message template's category changes, or is about to change.
# - `remote function onError(HandlerErrorEvent event) returns error?` — Invoked when any of the
#   handlers above returns an error while being dispatched for an incoming notification.
public type WhatsAppService distinct service object {
    // remote function onMessages(MessagesNotificationEvent event) returns error?;
    // remote function onAccountReviewUpdate(AccountReviewUpdateEvent event) returns error?;
    // remote function onAccountUpdate(AccountUpdateEvent event) returns error?;
    // remote function onBusinessCapabilityUpdate(BusinessCapabilityUpdateEvent event) returns error?;
    // remote function onMessageTemplateQualityUpdate(MessageTemplateQualityUpdateEvent event) returns error?;
    // remote function onMessageTemplateStatusUpdate(MessageTemplateStatusUpdateEvent event) returns error?;
    // remote function onPhoneNumberNameUpdate(PhoneNumberNameUpdateEvent event) returns error?;
    // remote function onPhoneNumberQualityUpdate(PhoneNumberQualityUpdateEvent event) returns error?;
    // remote function onSecurity(SecurityEvent event) returns error?;
    // remote function onTemplateCategoryUpdate(TemplateCategoryUpdateEvent event) returns error?;
    // remote function onError(HandlerErrorEvent event) returns error?;
};
