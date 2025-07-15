// test 2

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
/**
 * Generates the M-Pesa password for STK Push.
 * @param shortcode The M-Pesa Business Short Code.
 * @param passkey The M-Pesa Passkey.
 * @param timestamp The transaction timestamp.
 * @returns Base64 encoded password.
 */
function generatePassword(shortcode: string, passkey: string, timestamp: string): string {
  return btoa(shortcode + passkey + timestamp);
}

/**
 * Generates a timestamp in YYYYMMDDHHmmss format.
 * @returns The formatted timestamp string.
 */
function getTimestamp(): string {
  const now = new Date();
  const pad = (n: number) => n < 10 ? "0" + n : n.toString();
  return now.getFullYear().toString() +
         pad(now.getMonth() + 1) +
         pad(now.getDate()) +
         pad(now.getHours()) +
         pad(now.getMinutes()) +
         pad(now.getSeconds());
}

/**
 * Fetches the M-Pesa OAuth access token.
 * @returns The M-Pesa access token.
 * @throws Error if token request fails.
 */
async function getMpesaOAuthToken(): Promise<string> {
  if (!MPESA_CONSUMER_KEY || !MPESA_CONSUMER_SECRET) {
    throw new Error("M-Pesa Consumer Key or Secret not set in environment.");
  }
  const authString = btoa(`${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`);
  const tokenUrl = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"; // Use sandbox for development

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

// --- MAIN FUNCTION ---
serve(async (req) => {
  // --- Handle CORS Preflight ---
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }

  // Always catch errors, always send CORS!
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

    // Env sanity check for M-Pesa credentials
    if (!MPESA_BUSINESS_SHORTCODE || !MPESA_PASSKEY || !MPESA_CONSUMER_KEY || !MPESA_CONSUMER_SECRET) {
      return new Response(JSON.stringify({
        error: "One or more M-Pesa environment variables (BUSINESS_SHORTCODE, PASSKEY, CONSUMER_KEY, CONSUMER_SECRET) not set."
      }), {
        status: 500,
        headers: corsHeaders
      });
    }

    // Debug: log what we're sending
    console.log("M-Pesa BusinessShortCode:", MPESA_BUSINESS_SHORTCODE);

    const accessToken = await getMpesaOAuthToken();
    const timestamp = getTimestamp();
    const password = generatePassword(MPESA_BUSINESS_SHORTCODE, MPESA_PASSKEY, timestamp);

    // M-Pesa STK Push Query API call
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

    let updatedStatus = "Payment Failed"; // Default status for non-successful payments
    let mpesaReceiptNumber = null;

    // Determine the booking status based on M-Pesa ResultCode
    if (queryResult.ResultCode === "0") {
      updatedStatus = "Paid";
      mpesaReceiptNumber = queryResult.MpesaReceiptNumber;
    } else if (queryResult.ResultCode === "1032" || queryResult.ResultCode === "2001") {
      updatedStatus = "Cancelled";
    } else {
      // For other error codes, keep as "Payment Failed" or map more specifically if needed
      console.warn(`M-Pesa query returned non-success ResultCode: ${queryResult.ResultCode} - ${queryResult.ResultDesc}`);
    }

    // Update Supabase booking status
    let supabaseUpdateSuccess = false;
    if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
      const updateData: { status: string; mpesa_code?: string; payment_time: string } = {
        status: updatedStatus,
        payment_time: new Date().toISOString(),
      };
      if (mpesaReceiptNumber) {
        updateData.mpesa_code = mpesaReceiptNumber;
      }

      const { error } = await supabase.from("bookings")
        .update(updateData)
        .eq("id", bookingId);

      if (error) {
        console.error("Supabase update error:", error);
        return new Response(JSON.stringify({
          error: "Failed to update booking status in Supabase",
          details: error.message,
          mpesaResponse: queryResult // Include M-Pesa response for debugging
        }), {
          status: 500,
          headers: corsHeaders
        });
      }
      supabaseUpdateSuccess = true;
    } else {
      console.warn("Supabase URL or Service Role Key not set. Skipping Supabase update.");
    }

    // Always JSON, always CORS
    return new Response(JSON.stringify({
      ...queryResult, // Return the full M-Pesa response
      bookingStatusUpdated: supabaseUpdateSuccess,
      newBookingStatus: updatedStatus
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
      error: "An internal server error occurred during payment status query.",
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
