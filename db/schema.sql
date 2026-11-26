CREATE TABLE IF NOT EXISTS leads(id uuid PRIMARY KEY,name text NOT NULL,email text NOT NULL,country text NOT NULL,industry text NOT NULL,goal text NOT NULL,details text NOT NULL,offer text,preferred_time text,timezone text,consent_at timestamptz DEFAULT now(),stage text NOT NULL DEFAULT 'Discovered',owner text,next_action text NOT NULL DEFAULT 'Review request and respond',estimated_value integer,deadline timestamptz,evidence text,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS orders(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),offer text NOT NULL,amount integer NOT NULL CHECK(amount>0),currency text NOT NULL DEFAULT 'cad',stripe_session_id text UNIQUE,status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','paid','refunded')),created_at timestamptz DEFAULT now(),paid_at timestamptz);
CREATE TABLE IF NOT EXISTS payment_events(id text PRIMARY KEY,received_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS partners(id uuid PRIMARY KEY,company text NOT NULL,country text NOT NULL,specialization text NOT NULL,source_url text NOT NULL,contact_channel text,qualification text,status text DEFAULT 'Candidate',commercial_terms text,next_action text,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS projects(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),title text NOT NULL,status text NOT NULL DEFAULT 'Discovery',next_milestone text,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS audit_log(id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,entity_id uuid,action text NOT NULL,created_at timestamptz DEFAULT now());
CREATE INDEX IF NOT EXISTS leads_stage_idx ON leads(stage,created_at);

CREATE TABLE IF NOT EXISTS booking_slots(id uuid PRIMARY KEY,starts_at timestamptz NOT NULL UNIQUE,ends_at timestamptz NOT NULL,created_at timestamptz DEFAULT now(),CHECK(ends_at>starts_at));
CREATE TABLE IF NOT EXISTS bookings(id uuid PRIMARY KEY,slot_id uuid NOT NULL UNIQUE REFERENCES booking_slots(id),lead_id uuid NOT NULL REFERENCES leads(id),created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS portal_tokens(token_hash text PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),expires_at timestamptz NOT NULL,revoked_at timestamptz);
CREATE TABLE IF NOT EXISTS proposals(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),title text NOT NULL,scope text NOT NULL,amount integer NOT NULL CHECK(amount>=0),currency text NOT NULL DEFAULT 'cad',status text NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','sent','accepted','withdrawn')),created_at timestamptz DEFAULT now(),accepted_at timestamptz);
CREATE INDEX IF NOT EXISTS booking_slots_time_idx ON booking_slots(starts_at);
CREATE INDEX IF NOT EXISTS projects_client_idx ON projects(lead_id);
CREATE INDEX IF NOT EXISTS proposals_client_idx ON proposals(lead_id);

CREATE TABLE IF NOT EXISTS invoices(id uuid PRIMARY KEY,proposal_id uuid NOT NULL REFERENCES proposals(id),lead_id uuid NOT NULL REFERENCES leads(id),amount integer NOT NULL CHECK(amount>0),currency text NOT NULL DEFAULT 'cad',description text NOT NULL,seller text NOT NULL,status text NOT NULL DEFAULT 'issued' CHECK(status IN ('issued','paid','void')),created_at timestamptz DEFAULT now(),paid_at timestamptz);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS invoice_id uuid REFERENCES invoices(id);
CREATE UNIQUE INDEX IF NOT EXISTS orders_invoice_once ON orders(invoice_id) WHERE invoice_id IS NOT NULL;
CREATE TABLE IF NOT EXISTS intelligence(id uuid PRIMARY KEY,title text NOT NULL,source_url text NOT NULL,publisher text NOT NULL,published_at date,retrieved_at timestamptz DEFAULT now(),verification text NOT NULL CHECK(verification IN ('unreviewed','verified','rejected')),category text NOT NULL,market text NOT NULL,summary text NOT NULL,next_action text NOT NULL,owner text NOT NULL);
CREATE TABLE IF NOT EXISTS expenses(id uuid PRIMARY KEY,project_id uuid REFERENCES projects(id),category text NOT NULL CHECK(category IN ('internal','external')),amount integer NOT NULL CHECK(amount>0),currency text NOT NULL DEFAULT 'cad',description text NOT NULL,evidence text NOT NULL,incurred_at date NOT NULL,created_at timestamptz DEFAULT now());
