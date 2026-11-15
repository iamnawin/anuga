import {render,screen,fireEvent,waitFor} from '@testing-library/react';
import {ApiProvider} from '@/components/ApiProvider';
import {I18nProvider} from '@/components/I18nProvider';
import {VisitReturnQueue} from '@/components/VisitPlanTools';
import {createOpsApi,type RpcClient,type VisitPlanRow} from '@/lib/api';

const row:VisitPlanRow={trip_id:'synthetic',version:'v1',patient_id:'p1',patient_name:'Synthetic Patient',
  centre_name:'Synthetic Centre',status:'handed_over',stays_through_session:false,
  outbound_companion_name:'Asha',return_companion_name:'Asha',return_companion_id:'asha',
  outbound_start_at:'2026-11-15T07:00:00Z',outbound_end_at:'2026-11-15T08:00:00Z',
  expected_ready_at:'2026-11-15T12:00:00Z',return_prepare_at:'2026-11-15T11:30:00Z',
  return_arrive_by:'2026-11-15T11:45:00Z',return_end_at:'2026-11-15T13:00:00Z',
  handed_over_at:'2026-11-15T08:00:00Z',centre_ready_at:null,return_departed_at:null,return_arrived_at:null,
  return_due:true,return_late:true};

test('Ops sees delayed return and must supply actual centre confirmation; no automatic readiness',async()=>{
  const rpc=vi.fn(async(fn:string)=>({data:fn==='ops_visit_plans'?[row]:null,error:null}));
  const client={rpc,from:()=>{throw new Error('No direct table access');}} as RpcClient;
  const api=createOpsApi(client);
  render(<I18nProvider><ApiProvider api={()=>api}><VisitReturnQueue/></ApiProvider></I18nProvider>);
  expect(rpc).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole('button',{name:'Return pickup queue'}));
  await screen.findByText('Synthetic Patient — Synthetic Centre');
  expect(screen.getByText('Arrival overdue — contact companion or arrange backup')).not.toBeNull();
  const ready=screen.getByRole('button',{name:'Centre confirms patient ready'});
  expect((ready as HTMLButtonElement).disabled).toBe(true);
  expect(screen.queryByRole('button',{name:'Issue separate return code'})).toBeNull();
  fireEvent.change(screen.getByLabelText('Centre staff confirmation (internal, no clinical notes)'),{target:{value:'Staff called; ready (synthetic)'}});
  fireEvent.click(ready);
  await waitFor(()=>expect(rpc).toHaveBeenCalledWith('ops_confirm_centre_ready',{
    p_trip_id:'synthetic',p_expected_version:'v1',p_confirmation:'Staff called; ready (synthetic)',
  }));
});
