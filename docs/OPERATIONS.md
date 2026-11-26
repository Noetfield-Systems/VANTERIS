# Operating handbook
## Service delivery
Discovery → agreed scope, deliverables, exclusions, external fees and acceptance criteria → agreement → invoice/payment → milestone review → acceptance → renewal. Direct services are research, technology and project coordination; qualified external professionals separately handle reserved work. No guarantee of banking, licence or approval.
## Commercial configuration
Run npm install; configure PostgreSQL; npm run migrate; npm test; npm run build; npm start. On Railway use a dedicated project and PostgreSQL service. On Vercel use a separate authorized workspace and durable database. Configure DATABASE_URL and a random OPERATOR_TOKEN (at least 32 characters) in host secret settings. Never expose it to browser code. Set PUBLIC_BASE_URL to HTTPS, configure Stripe webhook /api/webhook, designate the legal seller and agree real delivery availability and terms before COMMERCE_ENABLED=true. Use test-mode keys to test before live. Do not infer ownership from GitHub organization.
## CRM
GET /api/operator (Bearer token) returns persisted leads, orders, partners and projects; PATCH updates lead stage, owner, next action and evidence; POST creates candidate partners or a project. Public enquiries POST /api/lead; paid offers POST /api/checkout. Preferred time is an enquiry, not a confirmed slot. Checkout returns do not verify payment.
## Acceptance
Unit tests cover catalogue and 120 routing combinations, validation, amount matching and webhook signature. CI must independently build. Integration tests with real PostgreSQL, booking, Stripe test webhook, tenant RBAC and accessibility/visual QA remain outstanding. No claim of competitive parity, revenue, partners or client portal readiness.
## Next deliveries
Client authentication and isolated portal, private storage, appointment calendar and confirmed slot locking, proposal/contract/invoice lifecycle, refund reconciliation, partner portal, 200 qualified prospects and 30 verified candidate partners, 18 researched jurisdiction dossiers, independent visual comparison and live QA.
