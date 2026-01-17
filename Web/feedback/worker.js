/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run "npm run dev" in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run "npm run deploy" to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
  async fetch(request, env) {
    // Only allow POST
    if (request.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }

    const url = new URL(request.url);
    if (url.pathname !== "/v1/feedback") {
      return new Response("Not found", { status: 404 });
    }

    let data;
    try {
      data = await request.json();
    } catch {
      return json({ error: "Invalid JSON" }, 400);
    }

    const message = (data.message || "").trim();
    if (!message) {
      return json({ error: "Message is required" }, 400);
    }

    if (message.length > 2000) {
      return json({ error: "Message too long" }, 400);
    }

    // New: user id handling
    const userId = (data.user_id || "").trim() || "unknown";

    const emailBody = `
New feedback received:

${message}

---
User ID: ${userId}
App version: ${data.app_version || "unknown"}
Platform: ${data.platform || "unknown"}
User agent: ${request.headers.get("User-Agent") || "unknown"}
    `.trim();

    const resendResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${env.RESEND_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: "Tipot Feedback <feedback@tipot.app>",
        to: ["tipot.drops@gmail.com"],
        subject: `User feedback ${userId}`,   // 👈 here
        text: emailBody
      })
    });

    if (!resendResponse.ok) {
      const text = await resendResponse.text();
      return json({ error: "Email send failed", detail: text }, 500);
    }

    return json({ ok: true });
  }
};

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    }
  });
}
