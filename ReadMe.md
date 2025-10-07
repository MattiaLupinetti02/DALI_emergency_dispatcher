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

1.1.1 Role Schemas

- Role Schema: HealthSensor

  - Description: Detects out-of-range vital parameters and alerts the WardManager.
  
  - Protocols and Activities: alarm, new_emergency.
  
  - Permissions:
  
    - Reads: new_systolic_pressure(Value), new_HR(Value), new_O2(Value), new_respiratory_rate(Value)
  
    - Generates: alarm(Ward,Patient,Values), new_emergency(Ward,Patient,Values)
  
  - Responsibilities:
  
    - Liveness: (new_vital_value → alarm → new_emergency)
  
    - Safety: alarms must be generated only if thresholds are exceeded.

- Role Schema: WardManager

  - Description: Coordinates the response within the ward, defines RRT, and interacts with HRCoordinator and Logger.

  - Protocols and Activities: human_resource_request, met_request, assign_rrt, emergency_handled.

  - Permissions:

    - Reads: alarm(Type,Val,Patient), met_assignment

    - Changes: available_staff(Ward)

    - Generates: human_resource_request(human_res_map,Ward), met_request, emergency_handled(Ward,Patient)

  - Responsibilities:

    - Liveness: (alarm → assign_rrt → met_request → emergency_handled)

    - Safety: must never assign RRT if available staff = 0.

- Role Schema: HRCoordinator

  - Description: Receives requests from WardManagers and assigns MET and human resources.
  
  - Protocols and Activities: human_resource_request, met_request, assign_human_resource, assign_met.
  
  - Permissions:
  
    - Reads: human_resource_request, met_request
    
    - Changes: human_resource_availability, met_status
    
    - Generates: met_assignment, assign_human_resource
  
  - Responsibilities:
  
    - Liveness: (human_resource_request → assign_human_resource) ∨ (met_request → assign_met)
    
    - Safety: avoid assigning already busy METs or unavailable staff.

- Role Schema: Logger

  - Description: Records all relevant events from the system and maintains their persistence.
  
  - Protocols and Activities: update_log_new_emergency, update_log_met_request, update_log_met_assignment, update_log_emergency_handled.
  
  - Permissions:
  
    - Reads: events received from other agents.
    
    - Changes: log file or database.
    
    - Generates: persistent log entries.
  
  - Responsibilities:
  
    - Liveness: (receive_event → update_log)
    
    - Safety: no duplicate log entries for the same event ID.

### 1.2 Virtual Organization

- **Name**: `EmergencyManagementSystem`
- **Goals**:
  - Minimize the latency time between the emergency accouring and the covering of the emergency.
  - Ensure the emergency covering and a smart dispatching of human resorces.
- **Roles and Interactions**:
  - `HealthSensor → WardManager`: sends alarm messages.
  - `WardManager → HRCoordinator`: sends Human Resources request and supplies.
  - `HRCoordinator → WardManager`: assign Human Resources and MET to an emergency. 
  - `All → Logger`: record of all relevant events and actions: MET assignment, Human Resources requests, emergency covering.

### 1.3 Interaction Model (Protocol Table)

| Protocol Name        | Initiator     | Responder     | Inputs               | Outputs                                      | Purpose                                                |
| -------------------- | ------------- | ------------- | -------------------- | -------------------------------------------- | ------------------------------------------------------ |
| `AlarmNotification`  | HealthSensor  | WardManager   | new vital values     | `alarm(Type,Val,Patient)`                    | Notify the WardManager of an abnormal vital parameter. |
| `ResourceRequest`    | WardManager   | HRCoordinator | `human_res_map,Ward` | `assign_human_resource`                      | Request human resources from HRCoordinator.            |
| `METRequest`         | WardManager   | HRCoordinator | emergency data       | `met_assignment`                             | Request MET assignment for a critical event.           |
| `ResourceAssignment` | HRCoordinator | WardManager   | available resources  | `human_resource_request(human_res_map,Ward)` | Assign new human resources to the ward.                |
| `METAssignment`      | HRCoordinator | WardManager   | MET availability     | `met_assignment`                             | Inform that MET has been assigned.                     |
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
| `alarm(low_systolic_pressure,Val,Patient)`        | external | HealthSensor      |
| `alarm(high_systolic_pressure,Val,Patient)`        | external | HealthSensor      |
| `alarm(low_O2,Val,Patient)`          | external | HealthSensor      |
| `alarm(low_HR,Val,Patient)`   | external | HealthSensor      |
| `alarm(high_HR,Val,Patient)`   | external | HealthSensor      |
| `alarm(low_respiratory_rate,Val,Patient)`   | external | HealthSensor      |
| `alarm(high_respiratory_rate,Val,Patient)`   | external | HealthSensor      |
| `human_resource_request(human_res_map,Ward)`   | external | HRCoordinator      |
| `assign_rrt`  |internal  |WardManager  |
| `met_assignment`   | external | HRCoordinator       |


#### HRCoordinator

| Event                | Type     | Source |
|----------------------|----------|-------------|
| `human_resource_request(human_res_map,From)`|external  |WardManager  |
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
| `alarm(Ward,Patient,Values)`   |Alerts the equipe of the ward about the new emergency|            |
| `new_emergency(Ward,Patient,Values)` | After the detection of a new emergency the Logger will be updated  |
#### WardManager

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `set_rrt`   | Define the rapid rescue team (RRT) in orider to handle the emergency aid  |
| `deacrease_available_equipe`   | After the RRT setting inside or outside the Ward decrease the available staff|
| `increase_available_equipe`   | After the RRT setting inside or outside the Ward decrease the available staff|
| `human_resource_request(human_res_map,From)`   | In case of insufficient specialized equipe the Ward Manager asks for some human resources from other wards |
| `met_request`  | In emergency case ask to the HR Coordinator for the Medical Emergency Team|
|  `emergency_handled(Ward,Patient)` | Once the emergency has been handled the Logger will be updated|
| `taking_charge_emergency` | Stops the alert generatin while the emergency is taken in charge |


#### HRCoordinator

| Action                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `human_resource_request(human_res_map,From)`   | Guides people to exit `X` safely  |
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
| `alarm`                  | SensorAgent      | vital parameters    | alarm message      | abnormal parameter detected | WardManager notified   |
| `new_emergency`          | SensorAgent      | alarm info          | log entry          | valid alarm                 | emergency logged       |
| `set_rrt`                | WardAgent        | alarm info          | RRT assignment     | staff available             | RRT active             |
| `human_resource_request` | WardAgent        | staff map, ward ID  | HR request         | insufficient staff          | HRCoordinator notified |
| `met_request`            | WardAgent        | emergency data      | MET request        | emergency critical          | MET assigned           |
| `assign_met`             | CoordinatorAgent | MET data, ward info | assignment message | MET available               | MET dispatched         |
| `assign_human_resource`  | CoordinatorAgent | staff list          | HR assignment      | available personnel         | staff assigned         |
| `update_log_*`           | LoggerAgent      | event data          | log record         | event valid                 | persistent log updated |

### 2.3 Acquaitance Model

| Source Agent  | Target Agent  | Communication Type | Purpose                             |
| ------------- | ------------- | ------------------ | ----------------------------------- |
| SensorAgent   | WardAgent     | Direct             | Send alarms                         |
| WardAgent     | HRCoordinator | Direct             | Request MET or human resources      |
| HRCoordinator | WardAgent     | Direct             | Send MET/human resource assignments |
| All Agents    | LoggerAgent   | Broadcast          | Update event logs                   |


#### Organizational Rules

  #### Scenario Example: Cardiac Arrest 

  1. HealthSensor detects abnormal HR → triggers alarm(WardA, PatientX, Values).

  2. WardManager receives the alarm and performs set_rrt.

  3. If staff is insufficient, WardManager performs human_resource_request(human_res_map,WardA).

  4. If the emergency is critical, WardManager also sends met_request.

  5. HRCoordinator receives the met_request, performs assign_met, and notifies WardManager.

  6. All actions and assignments are sent to Logger using update_log_* actions.

  7. When the emergency is resolved, WardManager executes emergency_handled(WardA,PatientX) and notifies Logger.

#### Trheshold Parameters


| Parameter         | Low Threshold | High Threshold |
| ----------------- | ------------- | -------------- |
| Systolic Pressure | < 90 mmHg     | > 180 mmHg     |
| Heart Rate        | < 40 bpm      | > 130 bpm      |
| O₂ Saturation     | < 90%         | —              |
| Respiratory Rate  | < 8 bpm       | > 30 bpm       |

