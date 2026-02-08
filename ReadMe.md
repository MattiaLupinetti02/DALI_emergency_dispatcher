# Multi-Agent System for Emergency Handling and Resources Dispatching in a smart-hospital

## Objective
Design and implement a multi-agent system in the DALI language for the detection and coordinated management of emergency as Cardiac Arrest, Acute Respiratory Distress and Severe Cardiovascular Instability.   

---

## Phase 1: Design according to the GAIA Methodology

### 1.1 Roles

| Role         | Main Responsibilities                                     |
|--------------|-----------------------------------------------------------|
| **HealthSensor**   | Detects out of range vital parameters.    |
| **Ward** | Manages the internal equipe defining the Rapid Rescue Team (RRT) and alerts the HRCoordinator in order to achieve extra HR. |
| **HRCoordinator**| Manages requests of human resources through the wards.                           |
| **Logger**   | Records all events, actions, and system status.           |
| **ValuesSimulator**   | Sends randomic vital signs to the HealthSensors|

### 1.1.1 Role Schemas

---

#### **Role Schema: HealthSensor**

- **Description:**  
  Detects out-of-range vital parameters ( systolic pressure and oxygen saturation) from the monitored patient.  
  When an anomaly is detected, it triggers an alarm to the Ward.  
  Once the Ward takes charge of the event, the HealthSensor stops generating repeated alarms.

- **Protocols and Activities:**  
  `configuration_phase`,`critical_*_out(Patient,*)`.

- **Permissions:**
  - **Reads:** `new_*(Patient,*)`,`taking_charge_emergency`,`emergency_handled`
  - **Generates:** `alarm(Values,Ward,Patient)`

- **Responsibilities:**
  - **Liveness:**  
    `(new_*(Value) → critical_*_out(Patient,*) → alarm(Ward,Patient,Values)`
  - **Safety:**  
    Alarms must be generated only if threshold limits are exceeded.  
    Avoid redundant alarms until `taking_charge_emergency` is received from the Ward, restart to monitor patients after receiving `emergency_handled`.

---

#### **Role Schema: Ward**

- **Description:**  
  Coordinates emergency handling within the ward.  
  Receives alarms from HealthSensor agents, defines the Rapid Rescue Team (RRT), updates local equipe availability, and interacts with the HRCoordinator to request or lend human resources.  
  It ensures that emergencies are promptly taken in charge and properly logged once resolved.

- **Protocols and Activities:**  
  `assign_rrt`, `configuration_phase`, `checkRRT(RRT, Equipe, Needy)`,  
  `get_value(Chiave, ListaCoppie, Default, Valore)`, `make_healthsensor_name(Patient, SensorName)`, `emergency_handled(Ward,Patient)`, `taking_charge_emergency`,`map_diff`,`map_sum`,`load_rrt`,`select_needy`, `add_external_equipe`.

- **Permissions:**
  - **Reads:** `alarmE(TP, WR, PT) `, `human_resource_reply(N,D,R,Receiver_Ward,Sender_Ward,Patient)`, `human_resource_request(N,D,R,Rec_Ward,Patient)`, `human_resource_restore_ward(N,D,R)`
  - **Changes:** `available_equipe(Ward)`
  - **Generates:** `human_resource_request(N,D,,R, Me, Patient)`,  `taking_charge_emergency`,  
    `def_urgency(TP, WR, PT)`, `emergency_handled(Ward,Patient)`,`assign_rrt(Result,Patient,Me)` `human_resource_restore_ward(Old_N, Old_D, Old_R, New_N, New_D, New_R, Ward_instance)`, `human_resource_lending(Patient,Rec_Ward,Send_Ward)`

- **Responsibilities:**
  - **Liveness:**  
    `(alarm  → def_urgency → assign_rrt → taking_charge_emergency → (emergency_handled(Ward,Patient)  ∧ (emergency_handled(Ward,Patient) ∨ (human_resource_restore_ward(Old_N, Old_D, Old_R, New_N, New_D, New_R, Ward_instance))) )`
  - **Safety:**  
    Must never execute `assign_rrt` if  `available_equipe(Ward)` is insufficient.  
    All alarms must trigger a response action within a defined time frame.

---

#### **Role Schema: HRCoordinator**

- **Description:**  
  Central coordinating agent that manages hospital-wide human resources requests.  
  Receives `human_resource_request(Nurses,N,Doctors,D,Resuscitators,R, From, Patient)` ,`human_resource_lending(Patient,Receiver_Ward,Sender_Ward)`, `stop_send_req(Receiver_Ward)` or `human_resource_restitution(N,D,R,Patient,Receiver_Ward,Sender_Ward)` messages from Wards, checks availability, and performs either `send_req(Requests, From, Patient)`, forwards ,`human_resource_restitution(N,D,R,Patient,Receiver_Ward,Sender_Ward)` to the lender ward.  
  Updates the Logger with each assignment to ensure full traceability.

- **Protocols and Activities:**  
  `configuration_phase`, `send_req(Requests, From, Patient)`
- **Permissions:**
  - **Reads:** `human_resource_request(Nurses,N,Doctors,D,Resuscitators,R, From, Patient)` ,`human_resource_lending(Patient,Receiver_Ward,Sender_Ward)`, `stop_send_req(Receiver_Ward)` or `human_resource_restitution(N,D,R,Patient,Receiver_Ward,Sender_Ward)`
  - **Changes:** `sended_req`,`emergency_timer`,`pending_req`,`pending_req_timer`,`hr_requests`,`to_send`
  - **Generates:** `human_resource_reply(N,D,R,Receiver_Ward,Sender_Ward,Patient)`, `human_resource_request(N,D,R,From,Patient)`,  
    `human_resource_lending(N,D,R,Receiver_Ward,Sender_Ward,Patient)`, `human_resource_restore_ward(N,D,R)`,`human_resource_restitution(N,D,R,Patient,Receiver_Ward,Sender_Ward)`

- **Responsibilities:**
  - **Liveness:**  
    `(human_resource_request(N,D,R, From, Patient) → send_req(Requests, From, Patient) → human_resource_lending(Patient,Receiver_Ward,Sender_Ward) → human_resource_reply(N,D,R,Receiver_Ward,Sender_Ward,Patient))  (human_resource_restitution(N,D,R,Patient,Receiver_Ward,Sender_Ward) → , human_resource_restore_ward(N,D,R)`
  - **Safety:**  
    Must avoid assigning already engaged HRs or unavailable personnel.  
    Guarantee coherence between `human_resource_lending` and global staff availability across wards.  

---

#### **Role Schema: Logger**

- **Description:**  
  Centralized logging agent responsible for recording every relevant event, action, and assignment within the system.  
  Maintains persistence of logs for traceability, analytics, and post-event auditing.  
  Receives updates from all other agents and stores them in a structured format.

- **Protocols and Activities:**  
  `atomic_list_concat`, `underscore_to_space`, `logger`, `format_number`, `def_timestamp`.

- **Permissions:**
  - **Reads:** incoming event notifications from `Ward`, and `HRCoordinator`
  - **Changes:** internal log.txt file 
  - **Generates:** persistent and timestamped log entries for each received event in log.txt file

- **Responsibilities:**
  - **Liveness:**  
    `(receive_event → define output → update log.txt`
  - **Safety:**  
    Guarantee one log entry per unique timestamp.  
    Maintain temporal order of logged events for accurate reconstruction.

---

### 1.2 Virtual Organization

- **Name**: `EmergencyManagementSystem`
- **Goals**:
  - Minimize the latency time between the emergency accouring and the covering of the emergency.
  - Ensure the emergency covering and a smart dispatching of human resorces.
- **Roles and Interactions**:
  - `HealthSensor → Ward`: sends alarm messages.
  - `Ward → HRCoordinator`: sends Human Resources requests and supplies and MET requests .
  - `HRCoordinator → Ward`: assign Human Resources and MET to an emergency, asks for Human Resources. 
  - `All → Logger`: record of all relevant events and actions: MET assignment, Human Resources requests, emergency covering.

### 1.3 Event Table

#### HealthSensor

| Event                | Type     | Source      |
|----------------------|----------|-------------|
| `new_*(Patient,Value)`          | external | ValuesSimulator |
| `taking_charge_emergency`   | external | Ward|
| `emergency_handled`   | external | Ward|
| `get_agent_name`   | Internal | HealthSensor|
| `set_ward`   | Internal | HealthSensor|
| `final_config_output`   | Internal | HealthSensor|

#### Ward

| Event                | Type     | Source      |
|----------------------|----------|-------------|
| `alarm(Type,Val,Patient)`        | external | HealthSensor      |
| `human_resource_reply(human_res_map,Ward)`   | external | HRCoordinator      |
| `human_resource_request(human_res_map,Ward)`   | external | HRCoordinator      |
| `human_resource_restore_ward(human_res_map)`   | external | HRCoordinator      |
| `assign_rrt`  |internal  |Ward  |
| `taking_charge_emergency`  |internal  |Ward  |
| `met_assignment`   | external | HRCoordinator       |


#### HRCoordinator

| Event                | Type     | Source |
|----------------------|----------|-------------|
| `human_resource_request(N,D,R, From, Patient)`|external  |Ward  |
| `human_resource_lending(Patient,Receiver_Ward,Sender_Ward)`|external  |Ward  |
| `human_resource_restitution(N,D,R,Patient,Receiver_Ward,Sender_Ward)` | external | Ward |
| `sending_tick` | internal | HRCoordinator |
| `timeout_tick` | internal | HRCoordinator |
| `send_req_to_wards`|internal  |HRCoordinator  |
| `read_wards`|internal  |HRCoordinator  |
| `stop_send_req(Receiver_Ward)`|external  |Ward  |

#### Logger

| Event                | Type     | Source |
|----------------------|----------|-------------|
| `new_emergency(Ward,Patient,Values)`|external|HealthSensor|
| `met_request(Ward)`|external|Ward|
| `met_assignment(Ward)`|external|HRCoordinator|
| `emergency_handled(Ward,Patient)`|external|Ward|


### 1.5 Action Table

#### HealthSensor

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `alarm(Ward,Patient,Values)`   |Alerts the equipe of the ward about the new emergency |
| `new_emergency(Ward,Patient,Values)` | After the detection of a new emergency the Logger will be updated  |

#### Ward

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `assign_rrt`   | Define the rapid rescue team (RRT) in orider to handle the emergency aid  |
| `deacrease_available_equipe(human_resources_map)`   | After the RRT setting inside or outside the Ward decrease the available staff|
| `increase_available_equipe(human_resources_map)`   | After the RRT setting inside or outside the Ward decrease the available staff|
| `human_resource_request(human_res_map,From)`   | In case of insufficient specialized equipe the Ward Manager asks for some human resources from other wards |
| `human_resource_lending(human_res_map,From)`   | In case of insufficient specialized equipe inside other wards the Ward Manager lends  some human resources |
| `human_resource_restitution(human_res_map,Ward)`   |  Return the Human Resources of lender Ward through the HRCoordinator|
| `met_request`  | In emergency case ask to the HR Coordinator for the Medical Emergency Team|
| `emergency_handled(Ward,Patient)` | Once the emergency has been handled the Logger will be updated|
| `taking_charge_emergency` | Stops the alert generatin while the emergency is taken in charge |


#### HRCoordinator

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `human_resource_reply(human_res_map,From)`   | Replies to the  Human Resource Request of the needy ward |
| `human_resource_request(human_res_map,From)`   | Forwards to other Ward the  Human Resource Request of the needy ward |
| `human_resource_restore_ward(human_res_map)`   | Forwards to the lender Ward the lended Human Resource Request from the needy ward |
| `met_assignment`   | Notify to the needy ward the MET assignment  |
| `met_assignment(Ward)`| Notifies the Logger that the MET has been assigned|


#### Logger

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `update_log_new_emergency(Ward,Patient,Values)`   | Add new emergency to the log file|
| `update_log_met_request(Ward)`   | Add new MET request the the log file|
| `update_log_met_assignment(Ward)`   | Specify the the ward where the MET has been assigned|
| `update_log_emergency_handled(Ward,Patient)`   | Fix an emergency as 'handled'|



## Phase 2: Design

| Agent Type         | Composed Roles | Instances                          | Notes                                           |
| ------------------ | -------------- | ---------------------------------- | ----------------------------------------------- |
| `SensorAgent`      | HealthSensor   | Multiple (1 per monitored patient) | Monitors vital parameters and generates alarms. |
| `WardAgent`        | Ward    | One per ward                       | Coordinates local emergency management.         |
| `CoordinatorAgent` | HRCoordinator  | Single instance                    | Central coordination of MET and HR.             |
| `LoggerAgent`      | Logger         | Single instance                    | Central log persistence service.                |


### 2.2 Services Model

| Service                  | Agent            | Inputs              | Outputs            | Preconditions               | Postconditions         |
| ------------------------ | ---------------- | ------------------- | ------------------ | --------------------------- | ---------------------- |
| `alarm`                  | SensorAgent      | vital parameters    | alarm message      | abnormal value detected | Ward notified   |
| `new_emergency`          | SensorAgent      | alarm info          | log entry          | valid alarm                 | emergency logged       |
| `assign_rrt`                | WardAgent        | alarm info          | RRT assignment     | staff available             | RRT active             |
| `human_resource_request` | WardAgent        | needed staff map, ward ID  | HR request         | insufficient staff          | HRCoordinator notified, message forwarded to other Wards |
| `human_resource_restitution` | WardAgent | Needed staff map, lender ward ID| Lender ward staff increasing | emergency_handled or met_assignment| Ward equipe descreases and the lender ward increase its equipe|
| `met_request`            | WardAgent        | ---    | MET request        | emergency critical          | MET assigned           |
| `met_assignment`             | CoordinatorAgent |  ward info | assignment message | MET available               | MET dispatched         |
| `assign_human_resource`  | CoordinatorAgent | staff map          | HR assignment      | available personnel         | staff assigned         |
| `update_log_*`           | LoggerAgent      | event data          | log record         | event valid                 | persistent log updated |

### 2.3 Acquaitance Model

| Source Agent  | Target Agent  | Communication Type | Purpose                             |
| ------------- | ------------- | ------------------ | ----------------------------------- |
| SensorAgent   | WardAgent     | Direct             | Send alarms                         |
| WardAgent     | HRCoordinator | Direct             | Request MET or human resources      |
| HRCoordinator | WardAgent     | Direct             | Send MET/human resource assignments |
| All Agents    | LoggerAgent   | Direct          | Update event logs                   |


#### Organizational Rules

  #### Scenario Example: Cardiac Arrest 

  1. HealthSensor detects abnormal HR → triggers alarm(WardA, PatientX, Values).

  2. Ward receives the alarm and performs assign_rrt.

  3. If staff is insufficient, Ward performs human_resource_request(human_res_map,WardA).

  4. If the emergency is critical, Ward also sends met_request.

  5. HRCoordinator receives the met_request, performs assign_met, and notifies Ward.

  6. All actions and assignments are sent to Logger using update_log_* actions.

  7. When the emergency is resolved, Ward executes emergency_handled(WardA,PatientX), if Ward performed human_resource_request(human_res_map,WardA) performs human_resource_restitution(human_res_map,WardA), and notifies Logger.

#### Trheshold Parameters


| Parameter         | Low Threshold | High Threshold |
| ----------------- | ------------- | -------------- |
| Systolic Pressure | < 90 mmHg     | > 180 mmHg     |
| Heart Rate        | < 40 bpm      | > 130 bpm      |
| O₂ Saturation     | < 90%         | —              |
| Respiratory Rate  | < 8 bpm       | > 30 bpm       |

