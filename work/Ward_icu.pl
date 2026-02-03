
:-dynamic ward_equipe/1.

:-dynamic my_instance_name/1.

:-dynamic my_ward_name/1.

:-dynamic my_ward_equipe/1.

:-dynamic equipe_read/1.

:-dynamic config/1.

config(0).

equipe_read(0).

my_instance_name('None').

get_agent_name(var_Name):-my_instance_name(var_Value),var_Value=='None'.

evi(get_agent_name(var__)):-setof(var_Base,(source_file(var__,var_Path),sub_atom(var_Path,var__,var__,var__,'Ward'),base_name(var_Path,var_Base)),var_Bases),var_Bases=[var_FirstBase|var__],(sub_atom(var_FirstBase,0,5,var_After,'Ward_')->sub_atom(var_FirstBase,5,var_After,0,var_Ward),retractall(my_ward_name(var__)),assertz(my_ward_name(var_Ward));write('ERRORE: Base non inizia con "Ward_": '),write(var_FirstBase),nl).

base_name(var_Path,var_Base):-atom(var_Path),atom_chars(var_Path,var_CharList),findall(var_Pos,nth0(var_Pos,var_CharList,'/'),var_SlashPositions),findall(var_Pos,nth0(var_Pos,var_CharList,'.'),var_PointPositions),(var_SlashPositions=[]->var_LastSlashPos= -1;last(var_SlashPositions,var_LastSlashPos)),(var_PointPositions=[]->(var_LastSlashPos= -1->var_Base=var_Path;var_StartPos is var_LastSlashPos+1,sub_atom(var_Path,var_StartPos,var__,0,var_Base));last(var_PointPositions,var_LastPointPos),var_StartPos is var_LastSlashPos+1,var_Length is var_LastPointPos-var_StartPos,sub_atom(var_Path,var_StartPos,var_Length,var__,var_Base)),retractall(my_instance_name(var__)),assertz(my_instance_name(var_Base)).

evi(read_wards):-open('reparti',read,var_Stream),read_loop(var_Stream),close(var_Stream),retractall(equipe_read(var__)),assertz(equipe_read(1)).

read_wards:-equipe_read(var_A),var_A=:=0,my_ward_name(var_Name).

read_loop(var_Stream):-read(var_Stream,var_Termine),(var_Termine==end_of_file->true;var_Termine=reparto(var_NomeReparto,var_Lista),(my_ward_name(var_Ward),var_NomeReparto==var_Ward->assertz(my_ward_equipe(var_Lista));true),read_loop(var_Stream)).

equipe_staff(['Nurses','Doctors','Resuscitators']).

evi(make_ward):-ward_equipe(var_Map),write('ward equipe setted:'),write(var_Map),nl,my_ward_name(var_Ward),write('ward name: '),write(var_Ward),nl,my_instance_name(var_Name),write('Instance name: '),write(var_Name),nl,write('end configuration'),nl.

make_ward:-my_ward_name(var_Name),config(var_V),var_V=:=0,my_instance_name(var_Inst_name),equipe_staff(var_Staff_list),my_ward_equipe(var_List),equipe_read(var_X),var_X=:=1,make_equipe(var_Staff_list,var_List,var_Map),assertz(ward_equipe(var_Map)),retractall(config(var__)),assertz(config(1)).

make_equipe([var_Prof_figure|var_Other_figures],[var_Value|var_Other_values],[var_Prof_figure-var_Value|var_Other_couples]):-make_equipe(var_Other_figures,var_Other_values,var_Other_couples).

make_equipe([],[],[]).

:-dynamic urgency/3.

:-dynamic rrt_assigned/1.

rrt([]).

rrt_format(['Nurses'-2,'Doctors'-1,'Resuscitators'-1]).

eve(alarm(var_TP,var_WR,var_PT)):-config(var_A),var_A=:=1,a(def_urgency(var_TP,var_WR,var_PT)).

a(def_urgency(var_TP,var_WR,var_PT)):-(retract(urgency(var_TP,var_WR,var_PT))->true;true),assertz(urgency(var_TP,var_WR,var_PT)).

tesg(checkRR(var_RRT,var_Equipe,var_Needy)):-tesg(checkRR(var_RRT,var_Equipe,[],var_Needy)).

tesg(checkRR([],var__,var_Acc,var_Acc)).

tesg(checkRR([var_Key-var_FVal|var_FT],var_Equipe,var_Acc,var_Needy)):-(member(var_Key-var_EVal,var_Equipe)->true;var_EVal=0),(var_EVal>=var_FVal->var_NewAcc=var_Acc;var_Missing is var_FVal-var_EVal,var_NewAcc=[var_Key-var_Missing|var_Acc]),tesg(checkRR(var_FT,var_Equipe,var_NewAcc,var_Needy)).

assign_rrt(var_Type,var_Ward,var_Patient):-config(1),urgency(var_Type,var_Ward,var_Patient),\+rrt_assigned(var_Patient),\+waiting_hr(var_Patient).

:-dynamic external_hr_request/1.

:-dynamic waiting_hr/1.

external_hr_request([]).

kv_to_need([],[]).

kv_to_need([var_K-var_V|var_T],[need(var_K,var_V)|var_NT]):-kv_to_need(var_T,var_NT).

evi(assign_rrt(var_Type,var_Ward,var_Patient)):-rrt_format(var_RRT),ward_equipe(var_Equipe),external_hr_request(var_Help_req_list),write('available equipe: '),write(var_Equipe),tesg(checkRR(var_RRT,var_Equipe,var_NeedyMap)),\+member(var_Patient-var_NeedyMap,var_Help_req_list),(var_NeedyMap==[]->load_rrt(var_RRT,var_Equipe,var_NewEquipe),retractall(ward_equipe(var__)),assertz(ward_equipe(var_NewEquipe)),assertz(rrt_assigned(var_Patient)),write('[OK] RRT assegnato al paziente: '),write(var_Patient),nl;assertz(waiting_hr(var_Patient)),my_instance_name(var_Me),write('[WARN] Risorse insufficienti: '),kv_to_need(var_NeedyMap,var_NeedList),write(var_NeedList),append(var_Help_req_list,[var_Patient-var_NeedyMap],var_New_help_req_list),retract(external_hr_request(var_Help_req_list)),assertz(external_hr_request(var_New_help_req_list)),get_value('Nurses',var_NeedyMap,0,var_N),get_value('Doctors',var_NeedyMap,0,var_D),get_value('Resuscitators',var_NeedyMap,0,var_R),a(message('HRCoordinator_instance',send_message(human_resource_request('Nurses',var_N,'Doctors',var_D,'Resuscitators',var_R,var_Me,var_Patient),var_Me)))),retractall(urgency(var__,var__,var_Patient)).

get_value(var_Chiave,var_ListaCoppie,var_Default,var_Valore):-member(var_Chiave-var_Valore,var_ListaCoppie)->true;var_Valore=var_Default.

make_healthsensor_name(var_Patient,var_SensorName):-my_ward_name(var_Ward),atom_concat('HealthSensor_',var_Ward,var_A1),atom_concat(var_A1,'_',var_A2),atom_concat(var_A2,var_Patient,var_SensorName).

taking_charge_emergency(var_Patient,var_Sensor):-rrt_assigned(var_Patient),\+waiting_hr(var_Patient),make_healthsensor_name(var_Patient,var_Sensor).

evi(taking_charge_emergency(var_Patient,var_Sensor)):-my_instance_name(var_Me),external_hr_request(var_Help_req_list),(member(var_Patient-var_List,var_Help_req_list)->rrt_format(var_Format),map_diff(var_Format,var_List,var_Old_equipe),retractall(ward_equipe(var__)),assertz(ward_equipe(var_Old_equipe)),select(var_Patient-var_List,var_Help_req_list,var_New_help_req_list);rrt_format(var_Format),ward_equipe(var_Equipe),map_sum(var_Format,var_Equipe,var_Old_equipe),write('per il paziente: '),write(var_Patient),write('prima c era: '),write(var_Equipe),write(' ora '),write(var_Old_equipe),nl,retractall(ward_equipe(var__)),assertz(ward_equipe(var_Old_equipe))),retractall(rrt_assigned(var_Patient)),write('Handled emergency for patient: '),write(var_Patient),nl.

map_diff([],[],[]).

map_diff([var_K-var_V1|var_T1],[var_K-var_V2|var_T2],[var_K-var_D|var_TD]):-var_D is var_V1-var_V2,map_diff(var_T1,var_T2,var_TD).

map_sum([],var__,[]).

map_sum([var_K-var_V1|var_T],var_Equipe,[var_K-var_D|var_TD]):-(member(var_K-var_V2,var_Equipe)->true;var_V2=0),var_D is var_V1+var_V2,map_sum(var_T,var_Equipe,var_TD).

relax_rrt([],var_Equipe,var_Equipe).

relax_rrt([var_Key-var_RRTVal|var_T],var_Equipe,var_FinalEquipe):-select(var_Key-var_EquipeVal,var_Equipe,var_Rest),var_NewVal is var_EquipeVal+var_RRTVal,load_rrt(var_T,[var_Key-var_NewVal|var_Rest],var_FinalEquipe).

load_rrt([],var_Equipe,var_Equipe).

load_rrt([var_Key-var_RRTVal|var_T],var_Equipe,var_FinalEquipe):-select(var_Key-var_EquipeVal,var_Equipe,var_Rest),var_NewVal is var_EquipeVal-var_RRTVal,load_rrt(var_T,[var_Key-var_NewVal|var_Rest],var_FinalEquipe).

select_needy(var_List,var_Result):-findall(var_Key-var_Value,(member(var_Key-var_Value,var_List),var_Value>0),var_Result).

:-dynamic lended_hr/1.

lended_hr([]).

eve(human_resource_request(var_Nurses,var_N,var_Doctors,var_D,var_Resuscitators,var_R,var_Rec_Ward,var_Patient)):-select_needy([var_Nurses-var_N,var_Doctors-var_D,var_Resuscitators-var_R],var_Requested),ward_equipe(var_Equipe),tesg(checkRR(var_Requested,var_Equipe,var_Needy)),(var_Needy==[]->load_rrt(var_Requested,var_Equipe,var_NewEquipe),retractall(ward_equipe(var__)),assertz(ward_equipe(var_NewEquipe)),my_instance_name(var_Send_Ward),a(message('HRCoordinator_instance',send_message(human_resource_lending(var_Patient,var_Rec_Ward,var_Send_Ward),var_Send_Ward)))),lended_hr(var_Old),append(old,[var_Ward],var_New),retractall(lended_hr(hr_requests)),assertz(lended_hr(var_New)).

add_external_equipe([]).

add_external_equipe([var_Hr-var_Num|var_Tail]):-ward_equipe(var_Equipe),member(var_Hr-var_Val,var_Equipe),var_NewVal is var_Val+var_Num,select(var_Hr-var_Val,var_Equipe,var_Temp),append(var_Temp,[var_Hr-var_NewVal],var_NewEquipe),retract(ward_equipe(var_Equipe)),assertz(ward_equipe(var_NewEquipe)),add_external_equipe(var_Tail).

eve(human_resource_reply(var_N,var_D,var_R,var_Receiver_Ward,var_Sender_Ward,var_Patient)):-waiting_hr(var_Patient),retractall(waiting_hr(var_Patient)),external_hr_request(var_Help_req_list),var_NeedyMap=['Nurses'-var_N,'Doctors'-var_D,'Resuscitators'-var_R],member(var_Patient-var_List,var_Help_req_list),add_external_equipe(var_List),ward_equipe(var_Equipe),write(var_Equipe),nl,rrt_format(var_Requested),load_rrt(var_Requested,var_Equipe,var_NewEquipe),retractall(ward_equipe(var__)),assertz(ward_equipe(var_NewEquipe)),assertz(rrt_assigned(var_Patient)),a(message('HRCoordinator_instance',send_message(human_resource_restitution(var_N,var_D,var_R,var_Receiver_Ward,var_Sender_Ward),var_Receiver_Ward))),nl,write('qua'),nl.

print_map([]).

print_map([var_K-var_V|var_T]):-format('key ~w~nvalue ~w~n',[var_K,var_V]),print_map(var_T).

stampa_lista([]).

stampa_lista([var_Head|var_Tail]):-write(var_Head),nl,stampa_lista(var_Tail).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

receive(send_message(var_X,var_Ag)):-told(var_Ag,send_message(var_X)),call_send_message(var_X,var_Ag).

receive(propose(var_A,var_C,var_Ag)):-told(var_Ag,propose(var_A,var_C)),call_propose(var_A,var_C,var_Ag).

receive(cfp(var_A,var_C,var_Ag)):-told(var_Ag,cfp(var_A,var_C)),call_cfp(var_A,var_C,var_Ag).

receive(accept_proposal(var_A,var_Mp,var_Ag)):-told(var_Ag,accept_proposal(var_A,var_Mp),var_T),call_accept_proposal(var_A,var_Mp,var_Ag,var_T).

receive(reject_proposal(var_A,var_Mp,var_Ag)):-told(var_Ag,reject_proposal(var_A,var_Mp),var_T),call_reject_proposal(var_A,var_Mp,var_Ag,var_T).

receive(failure(var_A,var_M,var_Ag)):-told(var_Ag,failure(var_A,var_M),var_T),call_failure(var_A,var_M,var_Ag,var_T).

receive(cancel(var_A,var_Ag)):-told(var_Ag,cancel(var_A)),call_cancel(var_A,var_Ag).

receive(execute_proc(var_X,var_Ag)):-told(var_Ag,execute_proc(var_X)),call_execute_proc(var_X,var_Ag).

receive(query_ref(var_X,var_N,var_Ag)):-told(var_Ag,query_ref(var_X,var_N)),call_query_ref(var_X,var_N,var_Ag).

receive(inform(var_X,var_M,var_Ag)):-told(var_Ag,inform(var_X,var_M),var_T),call_inform(var_X,var_Ag,var_M,var_T).

receive(inform(var_X,var_Ag)):-told(var_Ag,inform(var_X),var_T),call_inform(var_X,var_Ag,var_T).

receive(refuse(var_X,var_Ag)):-told(var_Ag,refuse(var_X),var_T),call_refuse(var_X,var_Ag,var_T).

receive(agree(var_X,var_Ag)):-told(var_Ag,agree(var_X)),call_agree(var_X,var_Ag).

receive(confirm(var_X,var_Ag)):-told(var_Ag,confirm(var_X),var_T),call_confirm(var_X,var_Ag,var_T).

receive(disconfirm(var_X,var_Ag)):-told(var_Ag,disconfirm(var_X)),call_disconfirm(var_X,var_Ag).

receive(reply(var_X,var_Ag)):-told(var_Ag,reply(var_X)).

send(var_To,query_ref(var_X,var_N,var_Ag)):-tell(var_To,var_Ag,query_ref(var_X,var_N)),send_m(var_To,query_ref(var_X,var_N,var_Ag)).

send(var_To,send_message(var_X,var_Ag)):-tell(var_To,var_Ag,send_message(var_X)),send_m(var_To,send_message(var_X,var_Ag)).

send(var_To,reject_proposal(var_X,var_L,var_Ag)):-tell(var_To,var_Ag,reject_proposal(var_X,var_L)),send_m(var_To,reject_proposal(var_X,var_L,var_Ag)).

send(var_To,accept_proposal(var_X,var_L,var_Ag)):-tell(var_To,var_Ag,accept_proposal(var_X,var_L)),send_m(var_To,accept_proposal(var_X,var_L,var_Ag)).

send(var_To,confirm(var_X,var_Ag)):-tell(var_To,var_Ag,confirm(var_X)),send_m(var_To,confirm(var_X,var_Ag)).

send(var_To,propose(var_X,var_C,var_Ag)):-tell(var_To,var_Ag,propose(var_X,var_C)),send_m(var_To,propose(var_X,var_C,var_Ag)).

send(var_To,disconfirm(var_X,var_Ag)):-tell(var_To,var_Ag,disconfirm(var_X)),send_m(var_To,disconfirm(var_X,var_Ag)).

send(var_To,inform(var_X,var_M,var_Ag)):-tell(var_To,var_Ag,inform(var_X,var_M)),send_m(var_To,inform(var_X,var_M,var_Ag)).

send(var_To,inform(var_X,var_Ag)):-tell(var_To,var_Ag,inform(var_X)),send_m(var_To,inform(var_X,var_Ag)).

send(var_To,refuse(var_X,var_Ag)):-tell(var_To,var_Ag,refuse(var_X)),send_m(var_To,refuse(var_X,var_Ag)).

send(var_To,failure(var_X,var_M,var_Ag)):-tell(var_To,var_Ag,failure(var_X,var_M)),send_m(var_To,failure(var_X,var_M,var_Ag)).

send(var_To,execute_proc(var_X,var_Ag)):-tell(var_To,var_Ag,execute_proc(var_X)),send_m(var_To,execute_proc(var_X,var_Ag)).

send(var_To,agree(var_X,var_Ag)):-tell(var_To,var_Ag,agree(var_X)),send_m(var_To,agree(var_X,var_Ag)).

call_send_message(var_X,var_Ag):-send_message(var_X,var_Ag).

call_execute_proc(var_X,var_Ag):-execute_proc(var_X,var_Ag).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),meta_ref(var_X,var_N,var_L,var_Ag),a(message(var_Ag,inform(query_ref(var_X,var_N),values(var_L),var_A))).

call_query_ref(var_X,var__,var_Ag):-clause(agent(var_A),var__),var(var_X),a(message(var_Ag,refuse(query_ref(variable),motivation(refused_variables),var_A))).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),not(meta_ref(var_X,var_N,var__,var__)),a(message(var_Ag,inform(query_ref(var_X,var_N),motivation(no_values),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),meta_agree(var_X,var_Ag),a(message(var_Ag,inform(agree(var_X),values(yes),var_A))).

call_confirm(var_X,var_Ag,var_T):-ground(var_X),statistics(walltime,[var_Tp,var__]),asse_cosa(past_event(var_X,var_T)),retractall(past(var_X,var_Tp,var_Ag)),assert(past(var_X,var_Tp,var_Ag)).

call_disconfirm(var_X,var_Ag):-ground(var_X),retractall(past(var_X,var__,var_Ag)),retractall(past_event(var_X,var__)).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),not(meta_agree(var_X,var__)),a(message(var_Ag,inform(agree(var_X),values(no),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),not(ground(var_X)),a(message(var_Ag,refuse(agree(variable),motivation(refused_variables),var_A))).

call_inform(var_X,var_Ag,var_M,var_T):-asse_cosa(past_event(inform(var_X,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_M,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_M,var_Ag),var_Tp,var_Ag)).

call_inform(var_X,var_Ag,var_T):-asse_cosa(past_event(inform(var_X,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_Ag),var_Tp,var_Ag)).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_565387,var_Ontology,_565391),_565381),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_565425)),a(message(var_Ag,propose(var_A,[_565425],var_AgI))),retractall(ext_agent(var_Ag,_565463,var_Ontology,_565467)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_565261,var_Ontology,_565265),_565255),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_565331,var_Ontology,_565335)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_565149,var_Ontology,_565153),_565143),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_565205,var_Ontology,_565209)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_564713),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_564747),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_564529).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_564377),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_564325),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_564201,_564203)),clause(agente(_564223,_564225,_564227,var_S),_564219),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_563995,_563997,_563999,var_S),_563991),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_564095,[]),repeat,read(_564095,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_564095).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(var_From,send_message(var_M)):-true.

told(var_Ag,execute_proc(var__)):-true.

told(var_Ag,query_ref(var__,var__)):-true.

told(var_Ag,agree(var__)):-true.

told(var_Ag,confirm(var__),200):-true.

told(var_Ag,disconfirm(var__)):-true.

told(var_Ag,request(var__,var__)):-true.

told(var_Ag,propose(var__,var__)):-true.

told(var_Ag,accept_proposal(var__,var__),20):-true.

told(var_Ag,reject_proposal(var__,var__),20):-true.

told(var__,failure(var__,var__),200):-true.

told(var__,cancel(var__)):-true.

told(var_Ag,inform(var__,var__),70):-true.

told(var_Ag,inform(var__),70):-true.

told(var_Ag,reply(var__)):-true.

told(var__,refuse(var__,var_Xp)):-functor(var_Xp,var_Fp,var__),var_Fp=agree.

tell(var_To,var_From,send_message(var_M)):-true.

tell(var_To,var__,confirm(var__)):-true.

tell(var_To,var__,disconfirm(var__)):-true.

tell(var_To,var__,propose(var__,var__)):-true.

tell(var_To,var__,request(var__,var__)):-true.

tell(var_To,var__,execute_proc(var__)):-true.

tell(var_To,var__,agree(var__)):-true.

tell(var_To,var__,reject_proposal(var__,var__)):-true.

tell(var_To,var__,accept_proposal(var__,var__)):-true.

tell(var_To,var__,failure(var__,var__)):-true.

tell(var_To,var__,query_ref(var__,var__)):-true.

tell(var_To,var__,eve(var__)):-true.

tell(var__,var__,refuse(var_X,var__)):-functor(var_X,var_F,var__),(var_F=send_message;var_F=query_ref).

tell(var_To,var__,inform(var__,var_M)):-true;var_M=motivation(refused_message).

tell(var_To,var__,inform(var__)):-true,var_To\=user.

tell(var_To,var__,propose_desire(var__,var__)):-true.

meta(var_P,var_V,var_AgM):-functor(var_P,var_F,var_N),var_N=0,clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_V,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_V,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_V,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_V,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_V,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_V,var_PreM,[var_RepM,var_HostM])),true,false),false)).

meta(var_P,var_V,var_AgM):-functor(var_P,var_F,var_N),(var_N=1;var_N=2),clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),var_P=..var_L,substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.

meta(var_P,var_V,var__):-functor(var_P,var_F,var_N),var_N=2,symmetric(var_F),var_P=..var_L,delete(var_L,var_F,var_R),reverse(var_R,var_R1),append([var_F],var_R1,var_R2),var_V=..var_R2.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),functor(var_P,var_F,var_N),var_N=2,(symmetric(var_F,var_AgM);symmetric(var_F)),var_P=..var_L,delete(var_L,var_F,var_R),reverse(var_R,var_R1),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_Y,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_Y,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_Y,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_Y,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_Y,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_Y,var_PreM,[var_RepM,var_HostM])),true,false),false)),append([var_Y],var_R1,var_R2),var_V=..var_R2.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),functor(var_P,var_F,var_N),var_N>2,if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),var_P=..var_L,substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),functor(var_P,var_F,var_N),var_N=2,var_P=..var_L,if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.
