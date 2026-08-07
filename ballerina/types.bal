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

import ballerina/data.jsondata;
import ballerina/http;

# Configuration for the WhatsApp Business Cloud `Client`.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # Bearer-token authentication (a system-user or temporary access token)
    @display {label: "Auth Config"}
    http:BearerTokenConfig auth;
    # The Meta Graph API version path segment used for every request (e.g. `v23.0`)
    string apiVersion = DEFAULT_API_VERSION;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_2_0;
    # Configurations related to HTTP/1.x protocol
    http:ClientHttp1Settings http1Settings = {};
    # Configurations related to HTTP/2 protocol
    http:ClientHttp2Settings http2Settings = {};
    # The maximum time to wait (in seconds) for a response before closing the connection
    decimal timeout = 30;
    # The choice of setting `forwarded`/`x-forwarded` header
    string forwarded = FORWARDED_DISABLE;
    # Configurations associated with redirection
    http:FollowRedirects followRedirects?;
    # Configurations associated with request pooling
    http:PoolConfiguration poolConfig?;
    # HTTP caching related configurations
    http:CacheConfig cache = {};
    # Specifies the way of handling compression (`accept-encoding`) header
    http:Compression compression = http:COMPRESSION_AUTO;
    # Configurations associated with the behaviour of the Circuit Breaker
    http:CircuitBreakerConfig circuitBreaker?;
    # Configurations associated with retrying
    http:RetryConfig retryConfig?;
    # Configurations associated with cookies
    http:CookieConfig cookieConfig?;
    # Configurations associated with inbound response size limits
    http:ResponseLimitConfigs responseLimits = {};
    # SSL/TLS-related options
    http:ClientSecureSocket secureSocket?;
    # Proxy server related options
    http:ProxyConfig proxy?;
    # Provides settings related to client socket configuration
    http:ClientSocketConfig socketConfig = {};
    # Enables the inbound payload validation functionality provided by the constraint package
    boolean validation = true;
    # Enables relaxed data binding on the client side
    boolean laxDataBinding = true;
|};

# A reference to a message being replied to.
public type MessageContext record {|
    # The WhatsApp message ID (`wamid...`) being replied to
    @jsondata:Name {value: "message_id"}
    string messageId;
|};

# A media attachment referenced either by a previously uploaded media ID or by a public link.
# Exactly one of `id`/`link` should be set.
public type MediaObject record {|
    # The ID of a media object already uploaded via `Client->uploadMedia`
    string id?;
    # A public URL Meta will fetch the media from
    string link?;
    # A caption shown with the media (not supported for audio)
    string caption?;
    # The filename shown to the recipient (documents only)
    string filename?;
|};

# A text message.
# See Meta's [text messages guide](https://developers.facebook.com/documentation/business-messaging/whatsapp/messages/text-messages).
public type TextMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID (phone number, international format, no leading `+`)
    string to;
    # Always `text`
    MESSAGE_TYPE_TEXT 'type = MESSAGE_TYPE_TEXT;
    # The message body
    record {|string body; @jsondata:Name {value: "preview_url"} boolean previewUrl?;|} text;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# An image message.
# See Meta's [image messages guide](https://developers.facebook.com/documentation/business-messaging/whatsapp/messages/image-messages).
public type ImageMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `image`
    MESSAGE_TYPE_IMAGE 'type = MESSAGE_TYPE_IMAGE;
    # The image, by media ID or link
    MediaObject image;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# An audio message.
# See Meta's [audio messages guide](https://developers.facebook.com/documentation/business-messaging/whatsapp/messages/audio-messages).
public type AudioMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `audio`
    MESSAGE_TYPE_AUDIO 'type = MESSAGE_TYPE_AUDIO;
    # The audio clip, by media ID or link
    MediaObject audio;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# A video message.
# See Meta's [video messages guide](https://developers.facebook.com/documentation/business-messaging/whatsapp/messages/video-messages).
public type VideoMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `video`
    MESSAGE_TYPE_VIDEO 'type = MESSAGE_TYPE_VIDEO;
    # The video, by media ID or link
    MediaObject video;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# A document message.
# See Meta's [document messages guide](https://developers.facebook.com/documentation/business-messaging/whatsapp/messages/document-messages).
public type DocumentMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `document`
    MESSAGE_TYPE_DOCUMENT 'type = MESSAGE_TYPE_DOCUMENT;
    # The document, by media ID or link
    MediaObject document;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# A location message.
# See Meta's [location messages guide](https://developers.facebook.com/documentation/business-messaging/whatsapp/messages/location-messages).
public type LocationMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `location`
    MESSAGE_TYPE_LOCATION 'type = MESSAGE_TYPE_LOCATION;
    # The location being shared
    record {|decimal longitude; decimal latitude; string name?; string address?;|} location;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# A contact's name, as shared in a `ContactMessage`.
public type ContactName record {|
    # The contact's full display name
    @jsondata:Name {value: "formatted_name"}
    string formattedName;
    # The contact's first name
    @jsondata:Name {value: "first_name"}
    string firstName?;
    # The contact's last name
    @jsondata:Name {value: "last_name"}
    string lastName?;
    # The contact's middle name
    @jsondata:Name {value: "middle_name"}
    string middleName?;
    # The contact's name suffix
    string suffix?;
    # The contact's name prefix
    string prefix?;
|};

# One phone number entry on a shared contact.
public type ContactPhone record {|
    # The phone number
    string phone?;
    # The kind of phone number, e.g. `CELL`, `MOBILE`, `MAIN`, `IPHONE`, `HOME`, or `WORK`. This is
    # a free-text label rather than a fixed enum, so any value is accepted
    string 'type?;
    # The number's WhatsApp ID, if it's a WhatsApp user
    @jsondata:Name {value: "wa_id"}
    string waId?;
|};

# One email entry on a shared contact.
public type ContactEmail record {|
    # The email address
    string email?;
    # The kind of email, e.g. `PERSONAL` or `WORK`. This is a free-text label rather than a fixed
    # enum, so any value is accepted
    string 'type?;
|};

# One postal address entry on a shared contact.
public type ContactAddress record {|
    # The street address
    string street?;
    # The city
    string city?;
    # The state or province
    string state?;
    # The postal code
    string zip?;
    # The country name
    string country?;
    # The two-letter country code
    @jsondata:Name {value: "country_code"}
    string countryCode?;
    # The kind of address, e.g. `HOME` or `WORK`. This is a free-text label rather than a fixed
    # enum, so any value is accepted
    string 'type?;
|};

# Organization details on a shared contact.
public type ContactOrg record {|
    # The company name
    string company?;
    # The department name
    string department?;
    # The contact's job title
    string title?;
|};

# One URL entry on a shared contact.
public type ContactUrl record {|
    # The URL
    string url?;
    # The kind of website, e.g. `COMPANY`, `WORK`, `PERSONAL`, `FACEBOOK PAGE`, or `INSTAGRAM`. This
    # is a free-text label rather than a fixed enum, so any value is accepted
    string 'type?;
|};

# A single shared contact card.
public type Contact record {|
    # The contact's name
    ContactName name;
    # The contact's phone numbers
    ContactPhone[] phones?;
    # The contact's email addresses
    ContactEmail[] emails?;
    # The contact's postal addresses
    ContactAddress[] addresses?;
    # The contact's organization details
    ContactOrg org?;
    # The contact's URLs
    ContactUrl[] urls?;
|};

# A message sharing one or more contact cards.
# See Meta's [contacts messages guide](https://developers.facebook.com/docs/whatsapp/cloud-api/messages/contacts-messages).
public type ContactMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `contacts`
    MESSAGE_TYPE_CONTACTS 'type = MESSAGE_TYPE_CONTACTS;
    # The contact cards being shared
    Contact[] contacts;
    # The message being replied to, if this is a reply
    MessageContext context?;
|};

# Any message can send.
public type Message TextMessage|ImageMessage|AudioMessage|VideoMessage|DocumentMessage|LocationMessage|ContactMessage;

# A currency value substituted into a template parameter.
public type TemplateCurrencyParameter record {|
    # The value shown if the template can't be localized to the recipient's locale
    @jsondata:Name {value: "fallback_value"}
    string fallbackValue;
    # The ISO 4217 currency code
    string code;
    # The amount, multiplied by 1000 (e.g. `15990` for `15.99`)
    @jsondata:Name {value: "amount_1000"}
    int amount1000;
|};

# A date/time value substituted into a template parameter.
public type TemplateDateTimeParameter record {|
    # The value shown if the template can't be localized to the recipient's locale
    @jsondata:Name {value: "fallback_value"}
    string fallbackValue;
|};

# One parameter substituted into a template's header or body text.
public type TemplateParameter record {|
    # The parameter kind: `text`, `currency`, `date_time`, or `image` (header media only)
    string 'type;
    # The substitution value, when `type` is `text`
    string text?;
    # The substitution value, when `type` is `currency`
    TemplateCurrencyParameter currency?;
    # The substitution value, when `type` is `date_time`
    @jsondata:Name {value: "date_time"}
    TemplateDateTimeParameter dateTime?;
    # The header media, when `type` is `image`
    MediaObject image?;
|};

# One populated component (header, body, or button) of a message template.
public type TemplateComponent record {|
    # The component kind: `header`, `body`, or `button`
    string 'type;
    # The parameters substituted into this component
    TemplateParameter[] parameters?;
    # The button kind (`quick_reply` or `url`); only present when `type` is `button`
    @jsondata:Name {value: "sub_type"}
    string subType?;
    # The zero-based button position on the template; only present when `type` is `button`
    int index?;
|};

# The template being sent, identified by name and language.
public type TemplateObject record {|
    # The template's name, as approved in the WhatsApp Manager
    string name;
    # The template's language
    record {|string code;|} language;
    # The template's populated header/body/button components
    TemplateComponent[] components?;
|};

# A pre-approved template message, required outside the 24-hour customer service window (e.g. the
# first message in a conversation). See Meta's [messages reference](https://developers.facebook.com/docs/whatsapp/cloud-api/reference/messages).
public type TemplateMessage record {|
    # Always `whatsapp`
    string messaging_product = MESSAGING_PRODUCT_WHATSAPP;
    # Always `individual`
    string recipient_type = RECIPIENT_TYPE_INDIVIDUAL;
    # The recipient's WhatsApp ID
    string to;
    # Always `template`
    MESSAGE_TYPE_TEMPLATE 'type = MESSAGE_TYPE_TEMPLATE;
    # The template to send
    TemplateObject template;
|};

# A recipient WhatsApp ID resolved from a `sendMessage`/`sendTemplateMessage` request.
#
# + input - The phone number supplied in the request
# + waId - The recipient's resolved WhatsApp ID
public type MessageRecipient record {
    string input;
    @jsondata:Name {value: "wa_id"}
    string waId;
};

# A message accepted by the WhatsApp Cloud API for delivery.
#
# + id - The unique WhatsApp message ID (`wamid...`)
public type SentMessage record {
    string id;
};

# The response returned after sending a message or template.
#
# + messaging_product - Always `whatsapp`
# + contacts - The resolved recipient(s)
# + messages - The accepted message(s)
public type MessageResponsePayload record {
    string messaging_product;
    MessageRecipient[] contacts?;
    SentMessage[] messages?;
};

# The file to upload as a reusable media object.
public type MediaUploadRequest record {|
    # The raw file bytes
    byte[] fileContent;
    # The filename sent with the upload
    string fileName;
    # The file's MIME type (e.g. `image/jpeg`, `application/pdf`)
    string mimeType;
|};

# The media ID assigned to an uploaded file. Use it in a `MediaObject.id` to send it, or with
# `retrieveMediaUrl`/`deleteMedia`.
#
# + id - The uploaded media's ID
public type MediaUploadResponse record {
    string id;
};

# The metadata and short-lived download URL for a media object.
#
# + url - A signed URL valid for a short time; fetch it (e.g. via `downloadMedia`) promptly
# + mimeType - The media's MIME type
# + sha256 - The SHA-256 checksum of the media's bytes
# + fileSize - The media's size, in bytes, as reported by Meta
# + id - The media's ID
public type MediaUrlResponse record {
    string url;
    @jsondata:Name {value: "mime_type"}
    string mimeType;
    string sha256;
    @jsondata:Name {value: "file_size"}
    string fileSize;
    string id;
};

# The result of deleting a media object.
#
# + success - Whether the delete succeeded
public type MediaDeleteResponse record {
    boolean success;
};
