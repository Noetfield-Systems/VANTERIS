export const MAX_FILE_BYTES=2*1024*1024;
export const MAX_CLIENT_BYTES=12*1024*1024;
export const MAX_TOTAL_BYTES=64*1024*1024;
export function classifyFile(buf,name,type){
 if(!Buffer.isBuffer(buf)||!buf.length||buf.length>MAX_FILE_BYTES||typeof name!=='string'||name.length>150)return null;
 const ext=name.toLowerCase().split('.').pop();
 if(type==='application/pdf'&&ext==='pdf'&&buf.subarray(0,5).toString()==='%PDF-')return type;
 if(type==='image/png'&&ext==='png'&&buf.subarray(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10])))return type;
 if(type==='image/jpeg'&&['jpg','jpeg'].includes(ext)&&buf[0]===255&&buf[1]===216&&buf[2]===255)return type;
 if(type==='text/plain'&&ext==='txt'&&!buf.includes(0)){try{new TextDecoder('utf-8',{fatal:true}).decode(buf);return type}catch{}}
 return null;
}
export function safeFileName(name){return name.replace(/[^a-zA-Z0-9._ -]/g,'_').replace(/^\.+/,'').slice(0,140)||'document'}
