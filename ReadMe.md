# DALI_GAIA_example

Title: __Multi-Agent System for Emergency Handling and Resources Dispatching in a smart-hospital

## Objective
Design and implement a multi-agent system in the DALI language for the detection and coordinated management of emergency as Cardiac Arrest, Respiratory Arrest, Acute Respiratory Distress, Severe Cardiovascular Instability, Systemic Disturbances, and Iatrogenic Complications.   

---

## Phase 1: Design according to the GAIA Methodology

### 1.1 Roles

| Role         | Main Responsibilities                                     |
|--------------|-----------------------------------------------------------|
| **HealthSensor**   | Detects out of range vital parameters.    |
| **WardManager** | Manages the internal equipe defining the Rapid Rescue Team (RRT) and alerts the . |
| **HRCoordinator**| Manages the Medical Emergency Team (MET) and the human resources through the wards.                           |
| **Logger**   | Records all events, actions, and system status.           |

---

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

---

### 1.3 Event Table

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


### 1.4 Action Table

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

### 1.5 Agent Behaviors

- **Sensor**: reactive; generates alarms upon detecting anomalies.
- **Coordinator**: reactive to incoming alarms; proactive in managing the response strategy.
- **Evacuator**: reactive to evacuation commands; can report issues or confirmation.
- **Logger**: reactive; logs every received message or command.

---
