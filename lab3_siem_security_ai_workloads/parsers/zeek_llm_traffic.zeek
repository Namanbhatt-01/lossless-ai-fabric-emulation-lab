##! Zeek Protocol Analyzer script for Deep Packet Inspection of AI REST / LLM API Traffic

module LLMTelemetry;

export {
    redef enum Log::ID += { LOG };

    type Info: record {
        ts: time &log;
        uid: string &log;
        id: conn_id &log;
        method: string &log;
        host: string &log;
        uri: string &log;
        request_body_len: count &log &default=0;
        response_body_len: count &log &default=0;
        is_ai_api: bool &log &default=F;
    };
}

event zeek_init() {
    Log::create_stream(LLMTelemetry::LOG, [$columns=Info, $path="ai_traffic"]);
}

event http_header(c: connection, is_orig: bool, name: string, value: string) {
    if (name == "HOST" && (value == "api.openai.com" || value == "api.anthropic.com" || value == "localhost:8000")) {
        # Mark connection as AI API traffic
    }
}
