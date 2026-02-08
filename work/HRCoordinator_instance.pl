
:-dynamic met/1.

:-dynamic wards/1.

:-dynamic equipe_read/1.

:-dynamic config/1.

config(0).

equipe_read(0).

met(0).

wards([]).

eve(shutdown):-write('Shutting down agent...'),nl,halt.

evi(read_wards):-open('reparti',read,var_Stream),read_loop(var_Stream),close(var_Stream),retractall(equipe_read(var__)),assertz(equipe_read(1)),wards(var_WardsList),write('Ward list:'),write(var_WardsList),nl.

read_wards:-equipe_read(var_A),var_A==0.

read_loop(var_Stream):-read(var_Stream,var_Termine),(var_Termine==end_of_file->true;var_Termine=reparto(var_NomeReparto,var_Lista),(wards(var_WardsList),append(var_WardsList,[var_NomeReparto],var_Temp),retractall(wards(var__)),assertz(wards(var_Temp));true),read_loop(var_Stream)).

:-dynamic pending_req/2.

:-dynamic pending_req_timer/4.

:-dynamic hr_requests/1.

:-dynamic to_send/3.

hr_requests([]).

select_needy(var_List,var_Result):-findall(var_Key-var_Value,(member(var_Key-var_Value,var_List),var_Value>0),var_Result).

eve(human_resource_request(var_Nurses,var_N,var_Doctors,var_D,var_Resuscitators,var_R,var_From,var_Patient)):-equipe_read(var_A),var_A==1,write('Request for HR for the patient: '),write(var_Patient),write(' from the ward: '),write(var_From),nl,var_List=['Nurses'-var_N,'Doctors'-var_D,'Resuscitators'-var_R],hr_requests(var_Old),\+member(var_From-[var_Patient-var_Vals],var_Old),select_needy(var_List,var_Result),append(var_Old,[var_From-[var_Patient-var_Result]],var_Requests),write('Current requests: '),write(var_Requests),nl,retractall(hr_requests(var__)),assertz(hr_requests(var_Requests)),send_req(var_Requests,var_From,var_Patient),a(message('Logger',send_message(human_resource_request(var_N,var_D,var_R,var_From,var_Patient),'HRCoordinator_instance'))),write('Request timeout started for HR: '),write(var_List),write('for the patient: '),write(var_Patient),write(' from the ward: '),write(var_From),nl.

send_req(var_Requests,var_From,var_Patient):-member(var_From-var_Value,var_Requests),member(var_Patient-var_Requested_equipe,var_Value)->wards(var_Wards),assertz(to_send(var_Patient,var_From,var_Wards)),assertz(sended_req(var_Receiver_Ward));true.

send_req_to_wards(var_Ward,var_Requested_equipe,var_From,var_Patient):-to_send(var_Patient,var_From,var_Wards),write(var_Wards),(var_Wards\=[]->last(var_Wards,var_Ward),select(var_Ward,var_Wards,var_Temp),retract(to_send(var_Patient,var_From,var_Wards)),assertz(to_send(var_Patient,var_From,var_Temp)),\+pending_req_timer(var_From,var_Ward,var_Patient,var__),hr_requests(var_Requests),member(var_From-var_Values,var_Requests),member(var_Patient-var_Requested_equipe,var_Values),write('fine'),nl;assertz(emergency_timer(var_From,var_Patient,2)),nl,retractall(to_send(var_Patient,var_From,var__))).

evi(send_req_to_wards(var_Ward,var_Request,var_From,var_Patient)):-ground(var_Request),ground(var_From),atom_concat('Ward_',var_Ward,var_Dest),write('Dest: '),write(var_Dest),nl,write('From: '),write(var_From),nl,(var_Dest==var_From->true;get_value('Nurses',var_Request,0,var_N),get_value('Doctors',var_Request,0,var_D),get_value('Resuscitators',var_Request,0,var_R),assertz(pending_req_timer(var_From,var_Dest,var_Patient,3)),a(message(var_Dest,send_message(human_resource_request('Nurses',var_N,'Doctors',var_D,'Resuscitators',var_R,var_From,var_Patient),'HRCoordinator_instance')))).

:-dynamic emergency_timer/3.

:-dynamic sended_req/1.

sending_tick(var_Requests,var_From,var_Dest,var_Patient,var_T):-hr_requests(var_Requests),pending_req_timer(var_From,var_Dest,var_Patient,var_T).

evi(sending_tick(var_Requests,var_From,var_Dest,var_Patient,var_T)):-write('[sending_tick] Patient '),write(var_Patient),write(' remaining: '),write(var_T),nl,write(var_From),nl,write(var_Requests),nl,(var_T>1->var_T1 is var_T-1,retractall(pending_req_timer(var_From,var_Dest,var_Patient,var__)),assertz(pending_req_timer(var_From,var_Dest,var_Patient,var_T1));member(var_From-var_P_list,var_Requests),write(pending_req_timer(var_From,var_Dest,var_Patient,var_T)),nl,write(send_req(var_Requests,var_From,var_Patient)),nl,retract(pending_req_timer(var_From,var_Dest,var_Patient,var__)),write('[END TIMEOUT SENDING REQUEST] for the patient: '),write(var_Patient),send_req(var_Requests,var_From,var_Patient)).

timeout_tick(var_Requests,var_From,var_Patient,var_T):-emergency_timer(var_From,var_Patient,var_T),hr_requests(var_Requests),member(var_From-var_Value,var_Requests),member(var_Patient-var_Req,var_Value).

evi(timeout_tick(var_Requests,var_From,var_Patient,var_T)):-write('[timeout_tick] Patient '),write(var_Patient),write(' remaining: '),write(var_T),nl,(var_T>1->var_T1 is var_T-1,retractall(emergency_timer(var_From,var_Patient,var__)),assertz(emergency_timer(var_From,var_Patient,var_T1));retractall(emergency_timer(var_From,var_Patient,var__)),write('[END TIMEOUT HR REQUEST] for the patient: '),write(var_Patient),nl,send_req(var_Requests,var_From,var_Patient)).

get_value(var_Chiave,var_ListaCoppie,var_Default,var_Valore):-member(var_Chiave-var_Valore,var_ListaCoppie)->true;var_Valore=var_Default.

eve(human_resource_lending(var_Patient,var_Receiver_Ward,var_Sender_Ward)):-retractall(emergency_timer(var_Receiver_Ward,var_Patient,var__)),retractall(to_send(var_Patient,var_Receiver_Ward,var__)),retractall(pending_req_timer(var_Receiver_Ward,var__,var_Patient,var__)),hr_requests(var_Requests),member(var_Receiver_Ward-var_Value,var_Requests),member(var_Patient-var_Requested_equipe,var_Value),select(var_Patient-var_Requested_equipe,var_Value,var_New_req_list),write('=====HR lended by Ward: '),write(var_Sender_Ward),write(' to '),write(var_Receiver_Ward),write('====='),nl,get_value('Nurses',var_Requested_equipe,0,var_N),get_value('Doctors',var_Requested_equipe,0,var_D),get_value('Resuscitators',var_Requested_equipe,0,var_R),a(message(var_Receiver_Ward,send_message(human_resource_reply(var_N,var_D,var_R,var_Receiver_Ward,var_Sender_Ward,var_Patient),'HRCoordinator_instance'))),a(message('Logger',send_message(human_resource_lending(var_N,var_D,var_R,var_Receiver_Ward,var_Sender_Ward,var_Patient),'HRCoordinator_instance'))).

eve(human_resource_restitution(var_N,var_D,var_R,var_Patient,var_Receiver_Ward,var_Sender_Ward)):-hr_requests(var_Req),write('=====HR restitution to the Ward to '),write(var_Sender_Ward),write(' from '),write(var_Receiver_Ward),write('====='),nl,write(var_Receiver_Ward),nl,member(var_Receiver_Ward-var_Ward_receiver_map,var_Req),select(var_Patient-var__,var_Ward_receiver_map,var_New_req_list),retractall(hr_requests(var_Req)),assertz(hr_requests(var_New_req_list)),write('HR again out of the ward: '),write(var_New_req_list),nl,write('====== RELEASED: '),write('N '),write(var_N),write(' D '),write(var_D),write(' R '),write(var_R),nl,a(message(var_Sender_Ward,send_message(human_resource_restore_ward(var_N,var_D,var_R),'HRCoordinator_instance'))),write('====== From '),write(var_Sender_Ward),write(' ======'),nl,retractall(sended_req(var_Receiver_Ward)),a(message('Logger',send_message(human_resource_restitution(var_N,var_D,var_R,var_Patient,var_Receiver_Ward,var_Sender_Ward),'HRCoordinator_instance'))).

eve(stop_send_req(var_Receiver_Ward)):-hr_requests(var_Req),write('in stop_send_req: '),write(var_Req),(sended_req(var_Receiver_Ward)->write('A HR request for '),write(var_Receiver_Ward),write(' already sended - impossible to release other request from this ward'),nl;write('All HR request for '),write(var_Receiver_Ward),write(' have been released '),nl,member(var_Receiver_Ward-var_Ward_receiver_map,var_Req),select(var_Receiver_Ward-var_Ward_receiver_map,var_Req,var_New_req_list),retractall(hr_requests(var_Req)),assertz(hr_requests(var_New_req_list)),retractall(emergency_timer(var_Receiver_Ward,var__,var__))).

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

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_549265,var_Ontology,_549269),_549259),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_549303)),a(message(var_Ag,propose(var_A,[_549303],var_AgI))),retractall(ext_agent(var_Ag,_549341,var_Ontology,_549345)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_549139,var_Ontology,_549143),_549133),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_549209,var_Ontology,_549213)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_549027,var_Ontology,_549031),_549021),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_549083,var_Ontology,_549087)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_548591),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_548625),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_548407).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_548255),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_548203),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_548079,_548081)),clause(agente(_548101,_548103,_548105,var_S),_548097),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_547873,_547875,_547877,var_S),_547869),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_547973,[]),repeat,read(_547973,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_547973).

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
