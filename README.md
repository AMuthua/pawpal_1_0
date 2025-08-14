PawPal: Pet Services Booking App 🐾
PawPal is a modern and intuitive mobile application built with Flutter, designed to connect pet owners with a variety of pet care services. The app allows users to seamlessly browse, book, and manage services such as dog walking, grooming, and boarding.

✨ Features
User Authentication: Secure sign-up and login with Supabase.

Pet Management: Users can add and manage profiles for multiple pets.

Service Booking: Browse and book various pet care services with customizable dates and times.

M-Pesa Integration: Secure and real-time payment processing for bookings via M-Pesa STK Push.

Booking History: View and manage past and upcoming bookings.

Real-time Status Updates: Real-time feedback on payment and booking status using Supabase streams.

💻 Technologies
Frontend: Flutter (for a cross-platform mobile application)

Backend: Supabase (BaaS - Database, Authentication, Functions)

Payment Gateway: M-Pesa Daraja API (via Supabase Edge Functions)

State Management: Provider

Routing: GoRouter

Database: PostgreSQL (managed by Supabase)

🚀 Installation
Follow these steps to get a local copy of the project up and running.

1. Clone the Repository
Bash

git clone https://github.com/[YourUsername]/PawPal.git
cd PawPal
2. Install Dependencies
Bash

flutter pub get
⚙️ Supabase Setup
PawPal relies on Supabase for its backend. You need to set up a new Supabase project and configure the database schema, authentication, and functions.

1. Create a New Supabase Project
Go to the Supabase Dashboard and create a new project.

Get your Project URL and Anon Key from the Settings > API section.

2. Configure Environment Variables
Create a file named .env in the root of your project with the following content:

Code snippet

SUPABASE_URL=[Your Supabase Project URL]
SUPABASE_ANON_KEY=[Your Supabase Anon Key]
3. Database Schema
Execute the following SQL commands in your Supabase SQL Editor to create the necessary tables and RLS policies.

profiles Table

SQL

create table public.profiles (
  id uuid not null references auth.users on delete cascade,
  updated_at timestamp with time zone,
  username text unique,
  full_name text,
  avatar_url text,
  phone_number text,
  primary key (id),
  unique (username),
  constraint username_length check (char_length(username) >= 3)
);
alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);
pets Table

SQL

create table public.pets (
  id uuid not null primary key default uuid_generate_v4(),
  owner_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  type text not null,
  breed text,
  age integer,
  image_url text
);
alter table public.pets enable row level security;
create policy "Pets are viewable by owner." on public.pets for select using (auth.uid() = owner_id);
create policy "Owners can insert their own pets." on public.pets for insert with check (auth.uid() = owner_id);
create policy "Owners can update their own pets." on public.pets for update using (auth.uid() = owner_id);
create policy "Owners can delete their own pets." on public.pets for delete using (auth.uid() = owner_id);
bookings Table

SQL

create table public.bookings (
  id uuid not null primary key default uuid_generate_v4(),
  owner_id uuid references public.profiles(id) on delete cascade not null,
  pet_id uuid references public.pets(id) on delete set null,
  service_type text not null,
  start_date date not null,
  end_date date,
  start_time time,
  special_instructions text,
  total_price numeric not null,
  status text not null,
  procedures jsonb
);
alter table public.bookings enable row level security;
create policy "Bookings are viewable by owner." on public.bookings for select using (auth.uid() = owner_id);
create policy "Owners can insert their own bookings." on public.bookings for insert with check (auth.uid() = owner_id);
create policy "Owners can update their own bookings." on public.bookings for update using (auth.uid() = owner_id);
💳 M-Pesa Integration
1. Daraja API Credentials
Sign up on the Safaricom Daraja Portal to get your Consumer Key and Consumer Secret.

Go to your Supabase project's Functions section.

Add the following secrets to your project:

MPESA_CONSUMER_KEY

MPESA_CONSUMER_SECRET

MPESA_BUSINESS_SHORTCODE

MPESA_PASSKEY

MPESA_CALLBACK_URL (This is your Supabase function's URL for the C2B callback).

2. Supabase Edge Functions
You need to deploy two Edge Functions for the M-Pesa integration.

mpesa-handler (for STK Push)
This function initiates the M-Pesa payment.

JavaScript

// A simplified example of the mpesa-handler function logic
// ... (Your actual M-Pesa STK push logic here)
// It will take phone, amount, and bookingId and return a CheckoutRequestID
mpesa-query-status (for Polling)
This function queries the status of a payment using the CheckoutRequestID.

JavaScript

// A simplified example of the mpesa-query-status function logic
// ... (Your actual M-Pesa status query logic here)
// It will take checkoutRequestId and bookingId, query the status,
// and update the 'bookings' table accordingly.
For detailed code for these functions, refer to the Supabase documentation or your own implementation.

▶️ Usage
Start the app:

Bash

flutter run
Sign up or log in to the application.

Add a pet profile.

Navigate to the booking section to book a service.

Select M-Pesa as the payment method to trigger the STK Push.

🤝 Contributing
Contributions are what make the open-source community an incredible place to learn, inspire, and create. Any contributions you make are greatly appreciated.

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

📄 License
Distributed under the MIT License. See LICENSE for more information.