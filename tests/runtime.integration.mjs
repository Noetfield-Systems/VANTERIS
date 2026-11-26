import test from 'node:test';import assert from 'node:assert/strict';
const base='http://127.0.0.1:3000',operator=process.env.OPERATOR_TOKEN;
async function call(path,{method='GET',token,body}={}){const r=await fetch(base+path,{method,headers:{...(token?{Authorization:'Bearer '+token}:{}),...(body?{'Content-Type':'application/json'}:{})},...(body?{body:JSON.stringify(body)}:{})});const raw=await r.text();let data;try{data=JSON.parse(raw)}catch{data=raw}return {status:r.status,data}}
const lead=(name,email)=>({name,email,country:'Canada',industry:'Cryptocurrency exchanges',goal:'Launch a business',details:'CI fixture for isolated runtime integration',consent:true});
test('live HTTP and isolated database: lead, booking conflict, portal isolation, invoice limits and intake rejection',async()=>{
  assert.equal((await call('/api/health')).status,200);
  assert.equal((await call('/api/operator')).status,401);
  assert.equal((await call('/api/lead',{method:'POST',body:{}})).status,400);
  const a=await call('/api/lead',{method:'POST',body:lead('CI Alpha','alpha@example.invalid')});
  const b=await call('/api/lead',{method:'POST',body:lead('CI Beta','beta@example.invalid')});
  assert.equal(a.status,201);assert.equal(b.status,201);
  const op=body=>call('/api/operations',{method:'POST',token:operator,body});
  const starts=new Date(Date.now()+86400000).toISOString(),ends=new Date(Date.now()+90000000).toISOString();
  const slot=await op({kind:'slot',starts_at:starts,ends_at:ends});assert.equal(slot.status,201);
  assert.equal((await op({kind:'slot',starts_at:starts,ends_at:ends})).status,409);
  const bookings=await Promise.all([call('/api/booking',{method:'POST',body:{...lead('CI Slot A','slota@example.invalid'),slot_id:slot.data.id}}),call('/api/booking',{method:'POST',body:{...lead('CI Slot B','slotb@example.invalid'),slot_id:slot.data.id}})]);
  assert.deepEqual(bookings.map(x=>x.status).sort(),[201,409]);
  const t1=await op({kind:'portal',lead_id:a.data.id}),t2=await op({kind:'portal',lead_id:b.data.id});assert.equal(t1.status,201);assert.equal(t2.status,201);
  const proposal=await op({kind:'proposal',lead_id:a.data.id,title:'CI proposal',scope:'Fixture technical scope',amount:10000});assert.equal(proposal.status,201);
  const view=token=>call('/api/portal',{token});
  assert.equal((await view(t1.data.token)).data.proposals.length,1);assert.equal((await view(t2.data.token)).data.proposals.length,0);
  const accept=token=>call('/api/portal',{method:'POST',token,body:{action:'accept',confirm:true,proposal_id:proposal.data.id}});
  assert.equal((await accept(t2.data.token)).status,409);assert.equal((await accept(t1.data.token)).status,200);
  const invoice=amount=>call('/api/finance',{method:'POST',token:operator,body:{kind:'invoice',proposal_id:proposal.data.id,description:'CI milestone',amount}});
  assert.equal((await invoice(6000)).status,201);assert.equal((await invoice(5000)).status,409);assert.equal((await invoice(4000)).status,201);
  assert.equal((await view(t1.data.token)).data.invoices.length,2);assert.equal((await view(t2.data.token)).data.invoices.length,0);
  assert.equal((await call('/api/checkout',{method:'POST',body:{...lead('CI Checkout','checkout@example.invalid'),offer:'consult'}})).status,503);
  const task=await call('/api/delivery',{method:'POST',token:operator,body:{kind:'task',lead_id:a.data.id,title:'CI onboarding',description:'Provide non-sensitive requirements'}});assert.equal(task.status,201);
  const deliver=token=>call('/api/delivery',{token});assert.equal((await deliver(t1.data.token)).data.tasks.length,1);assert.equal((await deliver(t2.data.token)).data.tasks.length,0);
  const respond=token=>call('/api/delivery',{method:'POST',token,body:{kind:'task_response',id:task.data.id,response:'CI fixture response'}});assert.equal((await respond(t2.data.token)).status,409);assert.equal((await respond(t1.data.token)).status,200);
  const ticket=await call('/api/delivery',{method:'POST',token:t1.data.token,body:{kind:'ticket',subject:'CI support',body:'CI fixture question'}});assert.equal(ticket.status,201);assert.equal((await deliver(t2.data.token)).data.tickets.length,0);
  assert.equal((await op({kind:'revoke_portal',lead_id:a.data.id})).status,200);assert.equal((await view(t1.data.token)).status,401);
  for(const path of ['/','/services','/services/fintech','/industries/0','/booking','/portal','/resources/1','/api/resources/1','/operator/finance','/jurisdictions/canada','/operator/delivery','/robots.txt']){const r=await fetch(base+path);assert.equal(r.status,200,path);await r.arrayBuffer()}
});
