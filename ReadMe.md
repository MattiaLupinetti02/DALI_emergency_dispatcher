# Multi-Agent System for Emergency Handling and Resources Dispatching in a smart-hospital

## Objective
Design and implement a multi-agent system in the DALI language for the detection and coordinated management of emergency as Cardiac Arrest, Respiratory Arrest, Acute Respiratory Distress, Severe Cardiovascular Instability, Systemic Disturbances, and Iatrogenic Complications.   

---

## Phase 1: Design according to the GAIA Methodology

### 1.1 Roles

| Role         | Main Responsibilities                                     |
|--------------|-----------------------------------------------------------|
| **HealthSensor**   | Detects out of range vital parameters.    |
| **WardManager** | Manages the internal equipe defining the Rapid Rescue Team (RRT) and alerts the HRCoordinator in order to achieve the Medical Emergency Team(MET). |
| **HRCoordinator**| Manages the Medical Emergency Team (MET) and the human resources through the wards.                           |
| **Logger**   | Records all events, actions, and system status.           |

### 1.1.1 Role Schemas

---

#### **Role Schema: HealthSensor**

- **Description:**  
  Detects out-of-range vital parameters (e.g., systolic pressure, heart rate, oxygen saturation, respiratory rate) from the monitored patient.  
  When an anomaly is detected, it triggers an alarm to the WardManager and updates the Logger about the new emergency.  
  Once the WardManager takes charge of the event, the HealthSensor stops generating repeated alarms.

- **Protocols and Activities:**  
  `alarm`, `new_emergency`, `taking_charge_emergency`.

- **Permissions:**
  - **Reads:** `new_systolic_pressure(Value)`, `new_HR(Value)`, `new_O2(Value)`, `new_respiratory_rate(Value)`
  - **Generates:** `alarm(Ward,Patient,Values)`, `new_emergency(Ward,Patient,Values)`

- **Responsibilities:**
  - **Liveness:**  
    `(new_*(Value) → alarm(Ward,Patient,Values) → new_emergency(Ward,Patient,Values))`
  - **Safety:**  
    Alarms must be generated only if threshold limits are exceeded.  
    Avoid redundant alarms until `taking_charge_emergency` is received from the WardManager.

---

#### **Role Schema: WardManager**

- **Description:**  
  Coordinates emergency handling within the ward.  
  Receives alarms from HealthSensor agents, defines the Rapid Rescue Team (RRT), updates local equipe availability, and interacts with the HRCoordinator to request or lend human resources or to obtain the Medical Emergency Team (MET).  
  It ensures that emergencies are promptly taken in charge and properly logged once resolved.

- **Protocols and Activities:**  
  `set_rrt`, `decrease_available_equipe(human_resources_map)`, `increase_available_equipe(human_resources_map)`,  
  `(human_res_map,Ward)`, `human_resource_lending(human_res_map,From)`,  
  `met_request`, `emergency_handled(Ward,Patient)`, `taking_charge_emergency`.

- **Permissions:**
  - **Reads:** `alarm(Type,Val,Patient)`, `human_resource_reply(human_res_map,Ward)`, `met_assignment`, `human_resource_restore_ward(human_res_map)`
  - **Changes:** `available_equipe(Ward)`
  - **Generates:** `human_resource_request(human_res_map,Ward)`,  
    `met_request`, `emergency_handled(Ward,Patient)`, `human_resource_restitution(Ward,human_res_map)`, `human_resource_lending(human_res_map,From)`

- **Responsibilities:**
  - **Liveness:**  
    `(alarm  → set_rrt → taking_charge_emergency → (emergency_handled(Ward,Patient)  ∧ (emergency_handled(Ward,Patient) ∨ (human_resource_restitution(Ward,human_res_map)  ∧ deacrease_available_equipe(human_resources_map))) )`
  - **Safety:**  
    Must never execute `set_rrt` if  `available_equipe(Ward)` is insufficient.  
    All alarms must trigger a response action within a defined time frame.  
    Ensure that all HR and MET requests are logged via Logger.

---

#### **Role Schema: HRCoordinator**

- **Description:**  
  Central coordinating agent that manages hospital-wide human resources and the Medical Emergency Team (MET).  
  Receives `human_resource_request(human_res_map,From)` ,`human_resource_restitution(Ward,human_res_map)`, `emergency_handled(Ward,Patient)` or `met_request` messages from WardManagers, checks availability, and performs either `assign_human_resource`, forwards ,`human_resource_restitution(Ward,human_res_map)` to the lender ward and/or `assign_met`.  
  Updates the Logger with each assignment to ensure full traceability.

- **Protocols and Activities:**  
  `human_resource_request(human_res_map,From)`, `human_resource_reply(human_res_map,From)`, `human_resource_lending(human_res_map,From)`,  
  `assign_human_resource`, `met_request`, `assign_met`, `met_assignment(Ward)`.

- **Permissions:**
  - **Reads:** `human_resource_request(human_res_map,From)`, `met_request`, `emergency_handled(Ward,Patient)`, `human_resource_restitution(Ward,human_res_map)`
  - **Changes:** `met_status`
  - **Generates:** `human_resource_reply(human_res_map,From)`, `met_assignment(Ward)`,  
    `assign_met`, `human_resource_restore_ward(human_res_map)`

- **Responsibilities:**
  - **Liveness:**  
    `(human_resource_request(human_res_map,From) → human_resource_reply(human_res_map,From)) ∨ (met_request → assign_met → met_assignment(Ward)) ∨ (human_resource_restitution(ward,human_res_map) → , human_resource_restore_ward(human_res_map))`
  - **Safety:**  
    Must avoid assigning already engaged METs or unavailable personnel.  
    Guarantee coherence between `human_resource_lending` and global staff availability across wards.  
    Ensure all MET and HR dispatches are reported to the Logger.

---

#### **Role Schema: Logger**

- **Description:**  
  Centralized logging agent responsible for recording every relevant event, action, and assignment within the system.  
  Maintains persistence of logs for traceability, analytics, and post-event auditing.  
  Receives updates from all other agents and stores them in a structured format.

- **Protocols and Activities:**  
  `update_log_new_emergency`, `update_log_met_request`, `update_log_met_assignment`, `update_log_emergency_handled`.

- **Permissions:**
  - **Reads:** incoming event notifications from `HealthSensor`, `WardManager`, and `HRCoordinator`
  - **Changes:** internal log file or database
  - **Generates:** persistent and timestamped log entries for each received event

- **Responsibilities:**
  - **Liveness:**  
    `(receive_event → update_log_new_emergency → update_log_met_request → update_log_met_assignment → update_log_emergency_handled)`
  - **Safety:**  
    Guarantee one log entry per unique event ID.  
    Ensure data persistence and recovery under network or system failures.  
    Maintain temporal order of logged events for accurate reconstruction.

---

### 1.2 Virtual Organization

- **Name**: `EmergencyManagementSystem`
- **Goals**:
  - Minimize the latency time between the emergency accouring and the covering of the emergency.
  - Ensure the emergency covering and a smart dispatching of human resorces.
- **Roles and Interactions**:
  - `HealthSensor → WardManager`: sends alarm messages.
  - `WardManager → HRCoordinator`: sends Human Resources requests and supplies and MET requests .
  - `HRCoordinator → WardManager`: assign Human Resources and MET to an emergency, asks for Human Resources. 
  - `All → Logger`: record of all relevant events and actions: MET assignment, Human Resources requests, emergency covering.

### 1.3 Interaction Model (Protocol Table)

| Protocol Name        | Initiator     | Responder     | Inputs               | Outputs                                      | Purpose                                                |
| -------------------- | ------------- | ------------- | -------------------- | -------------------------------------------- | ------------------------------------------------------ |
| `AlarmNotification`  | HealthSensor  | WardManager   | new vital values     | `alarm(Type,Val,Patient)`                    | Notify the WardManager of an abnormal vital parameter. |
| `ResourceRequest`    | WardManager   | HRCoordinator | `human_resource_request(human_res_map,Ward)` | `human_resource_reply(human_res_map,From)`                      | Request human resources from HRCoordinator.            |
| `METRequest`         | WardManager   | HRCoordinator | emergency data       | `met_request`                             | Request MET assignment for a critical event.           |
| `ResourceRestitution`| WardManager | HRCoordinator | `human_resource_restitution(Ward,human_res_map)`| `human_resource_restore_ward(human_res_map)` | 
| `LogUpdate`          | All           | Logger        | any event            | log entry                                    | Update system log with relevant data.                  |

### 1.4 Event Table

#### HealthSensor

| Event                | Type     | Source      |
|----------------------|----------|-------------|
| `new_systolic_pressure(Value)`        | external | environment |
| `new_O2(Value)`          | external | environment |
| `new_HR(Value)`   | external | environment |
| `new_respiratory_rate(Value)`   | external | environment |
| `taking_charge_emergency`   | external | WardManager|

#### WardManager

| Event                | Type     | Source      |
|----------------------|----------|-------------|
| `alarm(Type,Val,Patient)`        | external | HealthSensor      |
| `human_resource_reply(human_res_map,Ward)`   | external | HRCoordinator      |
| `human_resource_request(human_res_map,Ward)`   | external | HRCoordinator      |
| `human_resource_restore_ward(human_res_map)`   | external | HRCoordinator      |
| `assign_rrt`  |internal  |WardManager  |
| `taking_charge_emergency`  |internal  |WardManager  |
| `met_assignment`   | external | HRCoordinator       |


#### HRCoordinator

| Event                | Type     | Source |
|----------------------|----------|-------------|
| `human_resource_request(human_res_map,From)`|external  |WardManager  |
| `human_resource_lending(human_res_map,From)`|external  |WardManager  |
| `human_resource_restitution(Ward,human_res_map)` | external | WardManager |
| `met_request`|external  |WardManager  |
| `assign_met`|internal  |HRCoordinator  |
| `assign_human_resource`|internal  |HRCoordinator  |
| `emergency_handled`|external  |WardManager  |

#### Logger

| Event                | Type     | Source |
|----------------------|----------|-------------|
| `new_emergency(Ward,Patient,Values)`|external|HealthSensor|
| `met_request(Ward)`|external|WardManager|
| `met_assignment(Ward)`|external|HRCoordinator|
| `emergency_handled(Ward,Patient)`|external|WardManager|


### 1.5 Action Table

#### HealthSensor

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `alarm(Ward,Patient,Values)`   |Alerts the equipe of the ward about the new emergency |
| `new_emergency(Ward,Patient,Values)` | After the detection of a new emergency the Logger will be updated  |

#### WardManager

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `set_rrt`   | Define the rapid rescue team (RRT) in orider to handle the emergency aid  |
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
| `human_resource_request(human_res_map,From)`   | Forwards to other WardManager the  Human Resource Request of the needy ward |
| `human_resource_restore_ward(human_res_map)`   | Forwards to the lender WardManager the lended Human Resource Request from the needy ward |
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
| `WardAgent`        | WardManager    | One per ward                       | Coordinates local emergency management.         |
| `CoordinatorAgent` | HRCoordinator  | Single instance                    | Central coordination of MET and HR.             |
| `LoggerAgent`      | Logger         | Single instance                    | Central log persistence service.                |


### 2.2 Services Model

| Service                  | Agent            | Inputs              | Outputs            | Preconditions               | Postconditions         |
| ------------------------ | ---------------- | ------------------- | ------------------ | --------------------------- | ---------------------- |
| `alarm`                  | SensorAgent      | vital parameters    | alarm message      | abnormal value detected | WardManager notified   |
| `new_emergency`          | SensorAgent      | alarm info          | log entry          | valid alarm                 | emergency logged       |
| `set_rrt`                | WardAgent        | alarm info          | RRT assignment     | staff available             | RRT active             |
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

  2. WardManager receives the alarm and performs set_rrt.

  3. If staff is insufficient, WardManager performs human_resource_request(human_res_map,WardA).

  4. If the emergency is critical, WardManager also sends met_request.

  5. HRCoordinator receives the met_request, performs assign_met, and notifies WardManager.

  6. All actions and assignments are sent to Logger using update_log_* actions.

  7. When the emergency is resolved, WardManager executes emergency_handled(WardA,PatientX), if WardManager performed human_resource_request(human_res_map,WardA) performs human_resource_restitution(human_res_map,WardA), and notifies Logger.

#### Trheshold Parameters


| Parameter         | Low Threshold | High Threshold |
| ----------------- | ------------- | -------------- |
| Systolic Pressure | < 90 mmHg     | > 180 mmHg     |
| Heart Rate        | < 40 bpm      | > 130 bpm      |
| O₂ Saturation     | < 90%         | —              |
| Respiratory Rate  | < 8 bpm       | > 30 bpm       |

