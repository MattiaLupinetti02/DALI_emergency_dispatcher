```mermaid

graph TD

HS["HealthSensor"]
WM1["WardManager (Requester)"]
WM2["WardManager (Lender)"]
HRC["HRCoordinator"]
LOG["Logger"]

HS -->|alarm(Ward,Patient,Values)| WM1
HS -->|new_emergency(Ward,Patient,Values)| LOG
WM1 -->|taking_charge_emergency| HS

WM1 -->|human_resource_request(human_res_map,WardA)| HRC
HRC -->|forward_request(human_res_map,From=WardA)| WM2
WM2 -->|human_resource_lending(human_res_map,From=WardB)| HRC
HRC -->|human_resource_reply(human_res_map,From=WardB)| WM1

WM1 -->|met_request(WardA,PatientX)| HRC
HRC -->|met_assignment(WardA)| WM1

WM1 -->|emergency_handled(WardA,PatientX)| LOG
WM1 -->|human_resource_restitution(WardB,human_res_map)| HRC

HRC -->|assign_met / met_assignment| WM1
HRC -->|update_log_met_assignment| LOG

HS -->|update_log_new_emergency| LOG
WM1 -->|update_log_emergency_handled| LOG
HRC -->|update_log_met_assignment| LOG
