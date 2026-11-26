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

CREATE TABLE IF NOT EXISTS milestones(id uuid PRIMARY KEY,project_id uuid NOT NULL REFERENCES projects(id),title text NOT NULL,description text NOT NULL,due_at date,status text NOT NULL DEFAULT 'planned' CHECK(status IN ('planned','in_progress','review','accepted')),evidence text,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS client_tasks(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),title text NOT NULL,description text NOT NULL,status text NOT NULL DEFAULT 'open' CHECK(status IN ('open','submitted','accepted')),response text,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS support_tickets(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),subject text NOT NULL,body text NOT NULL,status text NOT NULL DEFAULT 'open' CHECK(status IN ('open','answered','closed')),reply text,created_at timestamptz DEFAULT now());
CREATE INDEX IF NOT EXISTS milestones_project_idx ON milestones(project_id);
CREATE INDEX IF NOT EXISTS tasks_lead_idx ON client_tasks(lead_id);
CREATE INDEX IF NOT EXISTS support_lead_idx ON support_tickets(lead_id);

CREATE TABLE IF NOT EXISTS agreements(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),proposal_id uuid NOT NULL REFERENCES proposals(id),title text NOT NULL,terms text NOT NULL,seller text NOT NULL,version integer NOT NULL DEFAULT 1,status text NOT NULL DEFAULT 'sent' CHECK(status IN ('sent','accepted','withdrawn')),accepted_at timestamptz,accepted_name text,created_at timestamptz DEFAULT now(),UNIQUE(proposal_id,version));
CREATE TABLE IF NOT EXISTS client_messages(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),sender text NOT NULL CHECK(sender IN ('client','operator')),body text NOT NULL,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS client_requests(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),title text NOT NULL,description text NOT NULL,status text NOT NULL DEFAULT 'new' CHECK(status IN ('new','reviewing','resolved')),created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS client_documents(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),title text NOT NULL,body text NOT NULL,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS assigned_specialists(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),display_name text NOT NULL,role text NOT NULL,scope text NOT NULL,created_at timestamptz DEFAULT now());
CREATE TABLE IF NOT EXISTS client_notifications(id uuid PRIMARY KEY,lead_id uuid NOT NULL REFERENCES leads(id),title text NOT NULL,body text NOT NULL,read_at timestamptz,created_at timestamptz DEFAULT now());
CREATE INDEX IF NOT EXISTS agreements_client_idx ON agreements(lead_id);
CREATE INDEX IF NOT EXISTS messages_client_idx ON client_messages(lead_id,created_at);
CREATE INDEX IF NOT EXISTS requests_client_idx ON client_requests(lead_id);
CREATE INDEX IF NOT EXISTS documents_client_idx ON client_documents(lead_id);
CREATE INDEX IF NOT EXISTS specialists_client_idx ON assigned_specialists(lead_id);
CREATE INDEX IF NOT EXISTS notifications_client_idx ON client_notifications(lead_id,created_at);
ALTER TABLE projects ADD COLUMN IF NOT EXISTS owner text;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS due_at date;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS acceptance_criteria text;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS dependencies text;

CREATE TABLE IF NOT EXISTS acquisition_records(id uuid PRIMARY KEY,kind text NOT NULL CHECK(kind IN ('prospect','partner')),company text NOT NULL,category text NOT NULL,source_url text NOT NULL,signal text NOT NULL,stage text NOT NULL DEFAULT 'discovered' CHECK(stage IN ('discovered','researching','qualified','drafted','contacted','replied','meeting','agreement','active','closed')),owner text NOT NULL,next_action text NOT NULL,next_date date,evidence text,commercial_model text,qualification text,created_at timestamptz DEFAULT now(),UNIQUE(kind,company));
CREATE TABLE IF NOT EXISTS acquisition_events(id uuid PRIMARY KEY,record_id uuid NOT NULL REFERENCES acquisition_records(id),event_type text NOT NULL CHECK(event_type IN ('research','draft','sent','reply','meeting','agreement','note')),body text NOT NULL,evidence text,created_at timestamptz DEFAULT now());
CREATE INDEX IF NOT EXISTS acquisition_stage_idx ON acquisition_records(kind,stage,next_date);
