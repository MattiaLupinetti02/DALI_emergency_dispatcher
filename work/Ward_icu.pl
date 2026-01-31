
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

equipe_staff(['nurses','doctors','resuscitators']).

evi(make_ward):-ward_equipe(var_Map),write('ward equipe setted:'),write(var_Map),nl,my_ward_name(var_Ward),write('ward name: '),write(var_Ward),nl,my_instance_name(var_Name),write('Instance name: '),write(var_Name),nl,write('end configuration'),nl.

make_ward:-my_ward_name(var_Name),config(var_V),var_V=:=0,my_instance_name(var_Inst_name),equipe_staff(var_Staff_list),my_ward_equipe(var_List),equipe_read(var_X),var_X=:=1,make_equipe(var_Staff_list,var_List,var_Map),assertz(ward_equipe(var_Map)),retractall(config(var__)),assertz(config(1)).

make_equipe([var_Prof_figure|var_Other_figures],[var_Value|var_Other_values],[var_Prof_figure-var_Value|var_Other_couples]):-make_equipe(var_Other_figures,var_Other_values,var_Other_couples).

make_equipe([],[],[]).

:-dynamic urgency/3.

:-dynamic rrt/1.

rrt([]).

rrt_format(['nurses'-2,'doctors'-1,'resuscitators'-1]).

eve(alarm(var_TP,var_WR,var_PT)):-config(var_A),var_A=:=1,a(def_urgency(var_TP,var_WR,var_PT)).

a(def_urgency(var_TP,var_WR,var_PT)):-(retract(urgency(var_TP,var_WR,var_PT))->true;true),assertz(urgency(var_TP,var_WR,var_PT)).

tesg(checkRR([],[])).

tesg(checkRR([var_Key_f-var_Value_f|var_Tail_f],[var_Key_e-var_Value_e|var_Tail_e])):-var_Value_e>=var_Value_f,tesg(checkRR(var_Tail_f,var_Tail_e)).

assign_rrt(var_Type,var_Ward,var_Patient):-config(var_A),var_A=:=1,findall(urgency(var_TP,var_WR,var_PT),urgency(var_TP,var_WR,var_PT),var_Lista),(var_Lista=[urgency(var_Type,var_Ward,var_Patient)|var__]->true;fail),rrt_format(var_Rrt_format_map),ward_equipe(var_Equipe_map),tesg(checkRR(var_Rrt_format_map,var_Equipe_map)).

evi(assign_rrt(var_Type,var_Ward,var_Patient)):-rrt_format(var_Rrt_format_map),ward_equipe(var_Equipe_map),load_rrt(var_Rrt_format_map,var_Equipe_map,var_NewEquipe),retractall(ward_equipe(var__)),assertz(ward_equipe(var_NewEquipe)),retractall(rrt(var__)),assertz(rrt(var_Patient)),write('Equipe updated: '),write(var_NewEquipe),nl,write('The assigned rrt is: '),write(var_Rrt_format_map),write(' to the patient '),write(var_Patient),nl.

make_healthsensor_name(var_Patient,var_SensorName):-my_ward_name(var_Ward),atom_concat('HealthSensor_',var_Ward,var_A1),atom_concat(var_A1,'_',var_A2),atom_concat(var_A2,var_Patient,var_SensorName).

taking_charge_emergency(var_Patient,var_SensorName):-my_ward_name(var_Ward),findall(rrt(var_P),rrt(var_P),var_Rrt_list),var_Rrt_list=[rrt(var_Patient)|var__],make_healthsensor_name(var_Patient,var_SensorName).

evi(taking_charge_emergency(var_Patient,var_SensorName)):-config(var_A),var_A=:=1,my_instance_name(var_AgentName),write('SensorName: '),write(var_SensorName),nl,a(message(var_SensorName,send_message('Takenincharge',var_AgentName))),retractall(urgency(var__,var__,var_Patient)),write('porcodio').

load_rrt([],var_Equipe,var_Equipe).

load_rrt([var_Key-var_RRTVal|var_T],var_Equipe,var_FinalEquipe):-select(var_Key-var_EquipeVal,var_Equipe,var_RestEquipe),var_NewVal is var_EquipeVal-var_RRTVal,var_NewEquipe=[var_Key-var_NewVal|var_RestEquipe],load_rrt(var_T,var_NewEquipe,var_FinalEquipe).

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

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_484263,var_Ontology,_484267),_484257),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_484301)),a(message(var_Ag,propose(var_A,[_484301],var_AgI))),retractall(ext_agent(var_Ag,_484339,var_Ontology,_484343)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_484137,var_Ontology,_484141),_484131),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_484207,var_Ontology,_484211)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_484025,var_Ontology,_484029),_484019),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_484081,var_Ontology,_484085)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_483589),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_483623),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_483405).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_483253),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_483201),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_483077,_483079)),clause(agente(_483099,_483101,_483103,var_S),_483095),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_482871,_482873,_482875,var_S),_482867),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_482971,[]),repeat,read(_482971,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_482971).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

allowed_sender_sensor(['HealthSensor_icu_p1','HealthSensor_icu_p2']).

allowed_receiver_sensor(['Ward_icu']).

tell(var_From,var_To,send_message(var_M)):-allowed_receiver_sensor(var_List_a),allowed_sender_sensor(var_List_b),memberchk(var_To,var_List_a),memberchk(var_From,var_List_b).

allowed_sender_simulator(['ValuesSimulator']).

allowed_receiver_simulator(['HealthSensor_icu_p1','HealthSensor_icu_p2']).

tell(var_From,var_To,send_message(var_M)):-allowed_receiver_simulator(var_List_a),allowed_sender_simulator(var_List_b),memberchk(var_To,var_List_a),memberchk(var_From,var_List_b).

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
