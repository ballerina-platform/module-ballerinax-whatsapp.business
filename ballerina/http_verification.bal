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
import ballerina/lang.array;

const string SIGNATURE_PREFIX = "sha256=";

# Verifies the `X-Hub-Signature-256` header against the raw webhook payload using HMAC-SHA256.
#
# + payload - The raw request body exactly as received
# + signatureHeader - The value of the `X-Hub-Signature-256` header (e.g. `sha256=...`)
# + appSecret - The Meta app secret used as the HMAC key
# + return - `true` if the signature is valid, `false` if it is not, or an error if the HMAC
# could not be computed
isolated function verifyWebhookSignature(string payload, string signatureHeader, string appSecret)
        returns boolean|error {
    byte[] digest = check crypto:hmacSha256(payload.toBytes(), appSecret.toBytes());
    string computed = SIGNATURE_PREFIX + array:toBase16(digest);
    return constantTimeEquals(computed, signatureHeader.trim());
}

# Compares two strings for equality in constant time (with respect to their shared length) to
# avoid leaking timing information about how much of the signature matched.
#
# + a - The first string
# + b - The second string
# + return - `true` if the strings are equal, `false` otherwise
isolated function constantTimeEquals(string a, string b) returns boolean {
    byte[] aBytes = a.toBytes();
    byte[] bBytes = b.toBytes();
    if aBytes.length() != bBytes.length() {
        return false;
    }
    int diff = 0;
    foreach int i in 0 ..< aBytes.length() {
        diff |= aBytes[i] ^ bBytes[i];
    }
    return diff == 0;
}
