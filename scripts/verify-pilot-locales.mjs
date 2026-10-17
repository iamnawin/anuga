// Real local phone/OTP presentation in te/hi; synthetic test numbers only.
import {createRequire} from 'node:module';
import {readFile,mkdir,writeFile} from 'node:fs/promises';
const require=createRequire(new URL('../apps/ops_console/package.json',import.meta.url));
const {chromium}=require('@playwright/test');
const browser=await chromium.launch({channel:'msedge',headless:true});
const output='artifacts/anu002-lifecycle/browser';await mkdir(output,{recursive:true});const results=[];
async function enter(field,text){for(let n=0;n<3;n++){await field.click();await field.press('Control+A');await field.pressSequentially(text,{delay:40});if(await field.inputValue()===text)return;}throw Error('Input was not accepted');}
try {
for(const app of ['family','companion','ops'])for(const lang of ['te','hi']){
 const context=await browser.newContext({viewport:{width:lang==='te'?360:1440,height:1000},colorScheme:lang==='te'?'dark':'light'});const page=await context.newPage();const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const copy=JSON.parse(await readFile('apps/'+(app==='ops'?'family':app)+'_app/lib/l10n/app_'+lang+'.arb','utf8'));
 await page.goto('http://127.0.0.1:3110'+(app==='ops'?'/ops/login/':'/'+app+'/'));
 if(app==='ops')await page.getByRole('combobox').selectOption(lang);
 else {await page.locator('flutter-view').waitFor({timeout:60000});await page.locator('flt-semantics-placeholder').evaluate(e=>e.click());await page.getByRole('button',{name:'Language',exact:true}).click();await page.getByRole('menuitem',{name:lang==='te'?'తెలుగు':'हिन्दी',exact:true}).click();}
 const send=app==='ops'?page.locator('button[type=submit]'):page.getByRole('button',{name:copy.sendCode,exact:true});
 await send.click();await page.waitForTimeout(500);await page.screenshot({path:output+'/'+app+'-phone-validation-'+lang+'.png'});
 const phone=app==='ops'?page.locator('#phone'):page.getByRole('textbox').first();
 await enter(phone,app==='ops'?'9000000001':app==='family'?'9000000101':'9000000202');
 await page.waitForTimeout(5500);await send.click();
 const code=app==='ops'?page.locator('#code'):page.getByRole('textbox',{name:copy.codeLabel,exact:true});await code.waitFor({timeout:30000});
 await page.waitForTimeout(1000);await page.screenshot({path:output+'/'+app+'-otp-'+lang+'.png'});
 await enter(code,'12');const verify=app==='ops'?page.locator('button[type=submit]'):page.getByRole('button',{name:copy.signIn,exact:true});await verify.click();
 await page.waitForTimeout(500);await page.screenshot({path:output+'/'+app+'-otp-validation-'+lang+'.png'});
 results.push({app,lang,width:lang==='te'?360:1440,theme:lang==='te'?'dark':'light',states:['phone validation','real OTP sent','code validation'],pageErrors:errors,nativeReview:'not performed'});
 await context.close();
}
await writeFile(output+'/locales.json',JSON.stringify(results,null,2));console.log(JSON.stringify(results));
}finally{await browser.close();}
