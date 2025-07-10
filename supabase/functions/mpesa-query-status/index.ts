import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// --- CORS HEADERS ---
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // <-- adjust to restrict if needed
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS"
};

// --- ENVIRONMENT VARIABLES ---
const MPESA_CONSUMER_KEY = Deno.env.get("MPESA_CONSUMER_KEY");
const MPESA_CONSUMER_SECRET = Deno.env.get("MPESA_CONSUMER_SECRET");
const MPESA_BUSINESS_SHORTCODE = Deno.env.get("MPESA_BUSINESS_SHORTCODE");
const MPESA_PASSKEY = Deno.env.get("MPESA_PASSKEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

// --- HELPERS ---
function generatePassword(shortcode: string, passkey: string, timestamp: string): string {
  return btoa(shortcode + passkey + timestamp);
}
function getTimestamp(): string {
  const now = new Date();
  const pad = (n: number)=>n < 10 ? "0" + n : n.toString();
  return now.getFullYear().toString()
    + pad(now.getMonth() + 1)
    + pad(now.getDate())
    + pad(now.getHours())
    + pad(now.getMinutes())
    + pad(now.getSeconds());
}
async function getMpesaOAuthToken(): Promise<string> {
  const authString = btoa(`${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`);
  const tokenUrl = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
  const res = await fetch(tokenUrl, {
    headers: {
      Authorization: `Basic ${authString}`
    }
  });
  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Token request failed: ${res.status} ${errorText}`);
  }
  const json = await res.json();
  return json.access_token;
}

// --- MAIN FUNCTION ---
serve(async (req) => {
  // --- Handle CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Always catch errors, always send CORS!
  try {
    const { checkoutRequestId, bookingId } = await req.json();

    if (!checkoutRequestId || !bookingId) {
      return new Response(
        JSON.stringify({ error: "Missing checkoutRequestId or bookingId" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Env sanity check
    if (!MPESA_BUSINESS_SHORTCODE) {
      return new Response(
        JSON.stringify({ error: "MPESA_BUSINESS_SHORTCODE not set in environment" }),
        { status: 500, headers: corsHeaders }
      );
    }

    // Debug: log what we're sending
    console.log("M-Pesa BusinessShortCode:", MPESA_BUSINESS_SHORTCODE);

    const accessToken = await getMpesaOAuthToken();
    const timestamp = getTimestamp();
    const password = generatePassword(MPESA_BUSINESS_SHORTCODE, MPESA_PASSKEY, timestamp);

    const mpesaRes = await fetch("https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        BusinessShortCode: MPESA_BUSINESS_SHORTCODE,
        Password: password,
        Timestamp: timestamp,
        CheckoutRequestID: checkoutRequestId
      })
    });

    const query = await mpesaRes.json();
    console.log("M-Pesa Query Response:", query);

    // Optionally update Supabase if payment confirmed
    let paymentUpdated = false;
    if (query.ResultCode === "0") {
      const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);
      const { error } = await supabase.from("bookings").update({
        status: "Paid",
        payment_confirmed: true,
        payment_time: new Date().toISOString(),
        mpesa_code: query.MpesaReceiptNumber
      }).eq("id", bookingId);

      if (error) {
        console.error("Supabase update error:", error);
        return new Response(JSON.stringify({
          error: "Failed to update booking",
          details: error.message
        }), { status: 500, headers: corsHeaders });
      }
      paymentUpdated = true;
    }

    // Always JSON, always CORS
    return new Response(JSON.stringify({
      ...query,
      paymentUpdated
    }), { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (err: any) {
    console.error("Status query error", err);
    return new Response(JSON.stringify({
      error: "Payment status query failed",
      details: err.message ?? String(err)
    }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
