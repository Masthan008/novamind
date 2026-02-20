// =============================================================
// Supabase Edge Function: push-notification
// Receives database webhook events and sends FCM notifications
// =============================================================
//
// Deploy: supabase functions deploy push-notification
//
// Required secrets (set via Supabase Dashboard > Edge Functions > Secrets):
//   FIREBASE_SERVICE_ACCOUNT_KEY  – The full JSON string of your Firebase
//                                    service account key file
// =============================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── CORS Headers ──────────────────────────────────────────────
const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

// ─── Firebase Admin SDK via REST API ───────────────────────────
// Since Deno doesn't support the full Firebase Admin SDK,
// we use the FCM HTTP v1 API directly with a service account JWT.

async function getAccessToken(): Promise<string> {
    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_KEY");
    if (!serviceAccountJson) {
        throw new Error("FIREBASE_SERVICE_ACCOUNT_KEY not set");
    }

    const serviceAccount = JSON.parse(serviceAccountJson);
    const now = Math.floor(Date.now() / 1000);

    // Create JWT header
    const header = { alg: "RS256", typ: "JWT" };

    // Create JWT claim set
    const claimSet = {
        iss: serviceAccount.client_email,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
    };

    // Encode to base64url
    const encoder = new TextEncoder();
    const headerB64 = btoa(String.fromCharCode(...encoder.encode(JSON.stringify(header))))
        .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
    const claimB64 = btoa(String.fromCharCode(...encoder.encode(JSON.stringify(claimSet))))
        .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

    const signInput = `${headerB64}.${claimB64}`;

    // Import private key and sign
    const pemContent = serviceAccount.private_key
        .replace("-----BEGIN PRIVATE KEY-----", "")
        .replace("-----END PRIVATE KEY-----", "")
        .replace(/\n/g, "");

    const binaryKey = Uint8Array.from(atob(pemContent), (c) => c.charCodeAt(0));

    const key = await crypto.subtle.importKey(
        "pkcs8",
        binaryKey,
        { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
        false,
        ["sign"]
    );

    const signature = await crypto.subtle.sign(
        "RSASSA-PKCS1-v1_5",
        key,
        encoder.encode(signInput)
    );

    const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
        .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

    const jwt = `${signInput}.${signatureB64}`;

    // Exchange JWT for access token
    const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    const tokenData = await tokenResponse.json();
    if (!tokenData.access_token) {
        throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
    }

    return tokenData.access_token;
}

// ─── Send FCM via HTTP v1 API ──────────────────────────────────

async function sendToTopic(
    accessToken: string,
    projectId: string,
    topic: string,
    title: string,
    body: string,
    data: Record<string, string> = {}
) {
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const message = {
        message: {
            topic: topic,
            notification: { title, body },
            data: data,
            android: {
                priority: "high",
                notification: {
                    channel_id: getChannelId(data.type || "general"),
                    sound: "default",
                },
            },
        },
    };

    const res = await fetch(url, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
    });

    const result = await res.json();
    console.log(`📤 Sent to topic '${topic}':`, JSON.stringify(result));
    return result;
}

async function sendToToken(
    accessToken: string,
    projectId: string,
    token: string,
    title: string,
    body: string,
    data: Record<string, string> = {}
) {
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const message = {
        message: {
            token: token,
            notification: { title, body },
            data: data,
            android: {
                priority: "high",
                notification: {
                    channel_id: getChannelId(data.type || "general"),
                    sound: "default",
                },
            },
        },
    };

    const res = await fetch(url, {
        method: "POST",
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
    });

    const result = await res.json();
    console.log(`📤 Sent to token:`, JSON.stringify(result));
    return result;
}

function getChannelId(type: string): string {
    switch (type) {
        case "news":
            return "fcm_news_channel";
        case "buzz_question":
        case "buzz_reply":
            return "fcm_buzz_channel";
        case "chat_message":
        case "chat_mention":
            return "fcm_chat_channel";
        default:
            return "fcm_news_channel";
    }
}

// ─── Main Handler ──────────────────────────────────────────────

serve(async (req: Request) => {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const payload = await req.json();
        console.log("📥 Webhook received:", JSON.stringify(payload));

        const table = payload.table;
        const record = payload.record;
        const eventType = payload.type;

        if (eventType !== "INSERT" || !record) {
            return new Response(
                JSON.stringify({ message: "Ignored (not an INSERT or no record)" }),
                { headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // Get Firebase access token
        const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_KEY");
        if (!serviceAccountJson) {
            throw new Error("FIREBASE_SERVICE_ACCOUNT_KEY not configured");
        }
        const serviceAccount = JSON.parse(serviceAccountJson);
        const projectId = serviceAccount.project_id;
        const accessToken = await getAccessToken();

        // Create Supabase client for looking up FCM tokens
        const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
        const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
        const supabase = createClient(supabaseUrl, supabaseKey);

        let result: any = { message: "No action" };

        // ─── NEWS ──────────────────────────────────────────────
        if (table === "news") {
            const title = record.title || "📰 New Update";
            const body = record.description || "Check the app for details";

            result = await sendToTopic(accessToken, projectId, "news", `📢 ${title}`, body, {
                type: "news",
                target_id: String(record.id || ""),
            });
        }

        // ─── CAMPUS BUZZ: NEW QUESTION ─────────────────────────
        else if (table === "student_doubts") {
            const studentName = record.student_name || "A student";
            const question = record.question || "Asked a question";
            const subject = record.subject || "General";

            result = await sendToTopic(
                accessToken,
                projectId,
                "campus_buzz",
                `💡 ${studentName} asked a question`,
                `[${subject}] ${question.substring(0, 100)}`,
                {
                    type: "buzz_question",
                    target_id: String(record.id || ""),
                    sender_name: studentName,
                }
            );
        }

        // ─── CAMPUS BUZZ: REPLY NOTIFICATION (TARGETED) ────────
        else if (table === "student_notifications") {
            const recipientId = record.recipient_id;
            const senderName = record.sender_name || "Someone";
            const message = record.message || "replied to your question";

            if (recipientId) {
                // Look up the recipient's FCM token
                const { data: tokenData } = await supabase
                    .from("user_fcm_tokens")
                    .select("fcm_token")
                    .eq("student_id", recipientId)
                    .single();

                if (tokenData?.fcm_token) {
                    result = await sendToToken(
                        accessToken,
                        projectId,
                        tokenData.fcm_token,
                        `💬 ${senderName}`,
                        message,
                        {
                            type: "buzz_reply",
                            target_id: String(record.doubt_id || record.id || ""),
                            sender_name: senderName,
                        }
                    );
                } else {
                    console.log(`⚠️ No FCM token for student ${recipientId}`);
                    result = { message: "No FCM token found for recipient" };
                }
            }
        }

        // ─── CHATHUB: NEW MESSAGE (BROADCAST) ──────────────────
        else if (table === "chat_messages") {
            const sender = record.sender || "Someone";
            const message = record.message || "Sent a message";

            result = await sendToTopic(
                accessToken,
                projectId,
                "chat_global",
                `💬 ${sender}`,
                message.substring(0, 200),
                {
                    type: "chat_message",
                    target_id: String(record.id || ""),
                    sender_name: sender,
                }
            );
        }

        // ─── CHATHUB: MENTION (TARGETED) ───────────────────────
        else if (table === "chat_mentions") {
            const mentionedUserId = record.mentioned_user_id;

            if (mentionedUserId) {
                // Get the original message
                const { data: msgData } = await supabase
                    .from("chat_messages")
                    .select("sender, message")
                    .eq("id", record.message_id)
                    .single();

                const sender = msgData?.sender || "Someone";
                const message = msgData?.message || "mentioned you";

                // Get the mentioned user's token
                const { data: tokenData } = await supabase
                    .from("user_fcm_tokens")
                    .select("fcm_token")
                    .eq("student_id", mentionedUserId)
                    .single();

                if (tokenData?.fcm_token) {
                    result = await sendToToken(
                        accessToken,
                        projectId,
                        tokenData.fcm_token,
                        `🔔 ${sender} mentioned you`,
                        message.substring(0, 200),
                        {
                            type: "chat_mention",
                            target_id: String(record.message_id || ""),
                            sender_name: sender,
                        }
                    );
                } else {
                    console.log(`⚠️ No FCM token for user ${mentionedUserId}`);
                    result = { message: "No FCM token found for mentioned user" };
                }
            }
        }

        return new Response(JSON.stringify({ success: true, result }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        console.error("❌ Error:", error);
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
        );
    }
});
