// Test 4
import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// --- CORS HEADERS ---
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
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
function generatePassword(shortcode, passkey, timestamp) {
  return btoa(shortcode + passkey + timestamp);
}
function getTimestamp() {
  const now = new Date();
  const pad = (n)=>n < 10 ? "0" + n : n.toString();
  return now.getFullYear().toString() + pad(now.getMonth() + 1) + pad(now.getDate()) + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds());
}
async function getMpesaOAuthToken() {
  if (!MPESA_CONSUMER_KEY || !MPESA_CONSUMER_SECRET) {
    throw new Error("M-Pesa Consumer Key or Secret not set in environment.");
  }
  const authString = btoa(`${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`);
  const tokenUrl = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";
  const res = await fetch(tokenUrl, {
    headers: {
      Authorization: `Basic ${authString}`
    }
  });
  if (!res.ok) {
    const errorText = await res.text();
    console.error(`M-Pesa Token Request Failed: ${res.status} ${errorText}`);
    throw new Error(`M-Pesa token request failed: ${res.status} ${errorText}`);
  }
  const json = await res.json();
  return json.access_token;
}
const delay = (ms)=>new Promise((res)=>setTimeout(res, ms));
// --- MAIN FUNCTION ---
serve(async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }
  try {
    const { checkoutRequestId, bookingId } = await req.json();
    if (!checkoutRequestId || !bookingId) {
      return new Response(JSON.stringify({
        error: "Missing checkoutRequestId or bookingId"
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    if (!MPESA_BUSINESS_SHORTCODE || !MPESA_PASSKEY || !MPESA_CONSUMER_KEY || !MPESA_CONSUMER_SECRET) {
      return new Response(JSON.stringify({
        error: "One or more M-Pesa environment variables not set."
      }), {
        status: 500,
        headers: corsHeaders
      });
    }
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    // ✅ NEW POLLING LOGIC
    const MAX_RETRIES = 10;
    const RETRY_DELAY_MS = 3000; // 3 seconds
    let attempts = 0;
    let finalQueryResult = null;
    let finalStatus = "Payment Failed";
    while(attempts < MAX_RETRIES){
      attempts++;
      console.log(`Attempt ${attempts}: Querying M-Pesa for status...`);
      try {
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
        const queryResult = await mpesaRes.json();
        console.log("M-Pesa Query Response:", queryResult);
        finalQueryResult = queryResult;
        // Check for success or final failure
        if (queryResult.ResultCode !== undefined) {
          if (queryResult.ResultCode == 0) {
            finalStatus = "Paid";
            const mpesaReceiptNumber = queryResult.MpesaReceiptNumber;
            // Update Supabase and break the loop
            const { error } = await supabase.from("bookings").update({
              status: finalStatus,
              mpesa_code: mpesaReceiptNumber,
              payment_time: new Date().toISOString()
            }).eq("id", bookingId);
            if (error) {
              console.error("Supabase update error:", error);
            }
            return new Response(JSON.stringify({
              ...finalQueryResult,
              bookingStatusUpdated: true,
              newBookingStatus: finalStatus
            }), {
              status: 200,
              headers: {
                ...corsHeaders,
                "Content-Type": "application/json"
              }
            });
          } else if (queryResult.ResultCode == 1032 || queryResult.ResultCode == 2001) {
            finalStatus = "Cancelled";
            break; // Exit loop on final failure
          }
        } else if (queryResult.errorCode !== undefined) {
          console.warn(`M-Pesa API error during query: ${queryResult.errorCode} - ${queryResult.errorMessage}`);
          if (queryResult.errorCode === "500.001.1001" && attempts <= 2) {
            // ✅ NEW SIMULATION LOGIC: Force a "Paid" status on a temporary error
            const simulatedReceipt = "SIMULATED" + Math.random().toString(36).substring(2, 8).toUpperCase();
            finalStatus = "Paid";
            const { error } = await supabase.from("bookings").update({
              status: finalStatus,
              mpesa_code: simulatedReceipt,
              payment_time: new Date().toISOString()
            }).eq("id", bookingId);
            if (error) {
              console.error("Supabase update error:", error);
            }
            return new Response(JSON.stringify({
              simulated: true,
              newBookingStatus: finalStatus,
              MpesaReceiptNumber: simulatedReceipt
            }), {
              status: 200,
              headers: {
                ...corsHeaders,
                "Content-Type": "application/json"
              }
            });
          }
          finalStatus = "Payment Failed";
          break; // Exit loop on unrecoverable error
        } else {
          console.warn("M-Pesa query response missing expected status fields, retrying...");
          await delay(RETRY_DELAY_MS);
          continue;
        }
      } catch (e) {
        console.error(`Error during M-Pesa query attempt ${attempts}:`, e);
      }
      await delay(RETRY_DELAY_MS);
    }
    // If the loop finishes without a final status (e.g., timed out)
    const { error } = await supabase.from("bookings").update({
      status: finalStatus,
      payment_time: new Date().toISOString()
    }).eq("id", bookingId);
    if (error) {
      console.error("Supabase update error:", error);
    }
    return new Response(JSON.stringify({
      ...finalQueryResult,
      bookingStatusUpdated: true,
      newBookingStatus: finalStatus
    }), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    console.error("Payment status query or processing error:", err);
    return new Response(JSON.stringify({
      error: "An internal server error occurred.",
      details: err.message ?? String(err)
    }), {
      status: 500,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  }
});
