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

import ballerina/crypto;
import ballerina/http;
import ballerina/test;

// A service declaring none of the ten (all-optional) handlers, so a `Listener` can be attached
// and started in handshake tests without caring about any particular event.
isolated service class MockWhatsAppService {
    *WhatsAppService;
}

isolated int messagesReceived = 0;

// Declares only the one handler it cares about, to verify the dispatcher correctly invokes a
// declared handler and silently skips every handler this service does not declare.
isolated service class MessagesOnlyWhatsAppService {
    *WhatsAppService;
    remote function onMessages(MessagesNotificationEvent event) returns error? {
        lock {
            messagesReceived += 1;
        }
    }
}

isolated int onErrorInvocations = 0;
isolated string onErrorLastField = "";

// Declares a failing `onSecurity` handler alongside `onError`, to verify `onError` is invoked with
// the failing handler's field/payload when the failing handler returns an error.
isolated service class FailingHandlerWhatsAppService {
    *WhatsAppService;
    remote function onSecurity(SecurityEvent event) returns error? {
        return error("boom");
    }
    remote function onError(HandlerErrorEvent event) returns error? {
        lock {
            onErrorInvocations += 1;
        }
        lock {
            onErrorLastField = event.'field;
        }
    }
}

const TEST_PORT = 18191;
const DISPATCH_TEST_PORT = 18192;
const ON_ERROR_TEST_PORT = 18193;

// The subscription handshake echoes the challenge only for a matching verify token and rejects a
// mismatch.
@test:Config {}
function testHandshakeWithVerifyToken() returns error? {
    Listener whatsappListener = check new (TEST_PORT, verifyToken = "secret-token", appSecret = "my-app-secret");
    check whatsappListener.attach(new MockWhatsAppService());
    check whatsappListener.'start();

    http:StatusCodeClient callerClient = check new (string `http://localhost:${TEST_PORT}`);

    http:Ok ok = check callerClient->get(
        "/?hub.mode=subscribe&hub.verify_token=secret-token&hub.challenge=challenge-1");
    test:assertEquals(ok?.body, "challenge-1", "challenge should be echoed");

    http:Forbidden forbidden = check callerClient->get(
        "/?hub.mode=subscribe&hub.verify_token=wrong-token&hub.challenge=challenge-1");
    test:assertEquals(forbidden?.body, ERR_WEBHOOK_VERIFICATION_FAILED, "a wrong token should be forbidden");

    check whatsappListener.immediateStop();
}

// Verifies the HMAC-SHA256 webhook signature verification end-to-end.
@test:Config {}
function testValidWebhookSignature() returns error? {
    string payload = {"object": "whatsapp_business_account", "entry": []}.toJsonString();
    string secret = "my-app-secret";
    byte[] hmac = check crypto:hmacSha256(payload.toBytes(), secret.toBytes());
    string signature = "sha256=" + hmac.toBase16().toLowerAscii();

    boolean valid = check verifyWebhookSignature(payload, signature, secret);
    test:assertTrue(valid, "a correctly signed payload should verify");
}

@test:Config {}
function testTamperedWebhookSignature() returns error? {
    string payload = {"object": "whatsapp_business_account"}.toJsonString();
    string secret = "my-app-secret";

    boolean valid = check verifyWebhookSignature(payload, "sha256=deadbeef", secret);
    test:assertFalse(valid, "a tampered signature should not verify");
}

@test:Config {}
function testWrongSecretWebhookSignature() returns error? {
    string payload = {"object": "whatsapp_business_account"}.toJsonString();
    byte[] hmac = check crypto:hmacSha256(payload.toBytes(), "right-secret".toBytes());
    string signature = "sha256=" + hmac.toBase16().toLowerAscii();

    boolean valid = check verifyWebhookSignature(payload, signature, "wrong-secret");
    test:assertFalse(valid, "signature computed with a different secret should not verify");
}

// Ensures the connector client can be initialized with bearer-token auth.
@test:Config {}
function testClientInitialization() returns error? {
    Client _ = check new ({auth: {token: "test-token"}});
}

// Verifies a service that declares only `onMessages` still receives `messages` notifications, and
// that other webhook fields are dropped silently (no error) since no handler is declared for them.
@test:Config {}
function testDispatchInvokesOnlyDeclaredHandler() returns error? {
    string secret = "my-app-secret";
    Listener whatsappListener = check new (DISPATCH_TEST_PORT, verifyToken = "secret-token", appSecret = secret);
    check whatsappListener.attach(new MessagesOnlyWhatsAppService());
    check whatsappListener.'start();

    http:StatusCodeClient callerClient = check new (string `http://localhost:${DISPATCH_TEST_PORT}`);

    string messagesPayload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "waba-1",
                "changes": [
                    {
                        "field": "messages",
                        "value": {
                            "messaging_product": "whatsapp",
                            "metadata": {"phone_number_id": "123"},
                            "messages": [
                                {"from": "111", "id": "wamid.1", "type": "text", "text": {"body": "hi"}}
                            ]
                        }
                    }
                ]
            }
        ]
    }.toJsonString();
    byte[] messagesHmac = check crypto:hmacSha256(messagesPayload.toBytes(), secret.toBytes());
    // A valid signed payload is accepted; binding to `http:Ok` itself asserts the 200 status.
    http:Ok _ = check callerClient->post("/", messagesPayload,
            headers = {[WEBHOOK_SIGNATURE_HEADER]: "sha256=" + messagesHmac.toBase16().toLowerAscii()});

    string securityPayload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "waba-1",
                "changes": [
                    {
                        "field": "security",
                        "value": {"display_phone_number": "111", "event": "PIN_CHANGED"}
                    }
                ]
            }
        ]
    }.toJsonString();
    byte[] securityHmac = check crypto:hmacSha256(securityPayload.toBytes(), secret.toBytes());
    // A field with no declared handler is still accepted (not delivered anywhere); binding to
    // `http:Ok` itself asserts the 200 status.
    http:Ok _ = check callerClient->post("/", securityPayload,
            headers = {[WEBHOOK_SIGNATURE_HEADER]: "sha256=" + securityHmac.toBase16().toLowerAscii()});

    lock {
        test:assertEquals(messagesReceived, 1, "onMessages should have been invoked exactly once");
    }

    check whatsappListener.immediateStop();
}

// Verifies `onError` is invoked with the failing handler's field/payload when a handler returns an
// error, and that the ack to Meta still succeeds (dispatch failures never affect the response).
@test:Config {}
function testOnErrorInvokedWhenHandlerFails() returns error? {
    string secret = "my-app-secret";
    Listener whatsappListener = check new (ON_ERROR_TEST_PORT, verifyToken = "secret-token", appSecret = secret);
    check whatsappListener.attach(new FailingHandlerWhatsAppService());
    check whatsappListener.'start();

    http:StatusCodeClient callerClient = check new (string `http://localhost:${ON_ERROR_TEST_PORT}`);

    string securityPayload = {
        "object": "whatsapp_business_account",
        "entry": [
            {
                "id": "waba-1",
                "changes": [
                    {
                        "field": "security",
                        "value": {"display_phone_number": "111", "event": "PIN_CHANGED"}
                    }
                ]
            }
        ]
    }.toJsonString();
    byte[] securityHmac = check crypto:hmacSha256(securityPayload.toBytes(), secret.toBytes());
    // The failing onSecurity handler must not affect the ack; binding to `http:Ok` itself asserts
    // the 200 status.
    http:Ok _ = check callerClient->post("/", securityPayload,
            headers = {[WEBHOOK_SIGNATURE_HEADER]: "sha256=" + securityHmac.toBase16().toLowerAscii()});

    lock {
        test:assertEquals(onErrorInvocations, 1, "onError should have been invoked exactly once");
    }
    lock {
        test:assertEquals(onErrorLastField, "security", "onError should report the failing handler's field");
    }

    check whatsappListener.immediateStop();
}
