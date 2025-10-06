```mermaid
sequenceDiagram
  autonumber
  participant HealthSensor
  participant WardManager
  participant HRCoordinator
  participant Logger

  %% Sensor detects emergency
  HealthSensor->>WardManager: alarm(WardA,PatientX,Values)
  Note right of WardManager: EvaluateEmergency

  %% WardManager local response
  WardManager->>WardManager: set_rrt
  WardManager->>Logger: update_log_new_emergency(WardA,PatientX,Values)

  %% If insufficient staff or critical
  WardManager->>HRCoordinator: human_resource_request(human_res_map,WardA)
  WardManager->>HRCoordinator: met_request

  %% HRCoordinator assigns MET / resources
  HRCoordinator->>WardManager: met_assignment(WardA)
  HRCoordinator->>WardManager: assign_human_resource(StaffList)

  %% Logging assignments
  WardManager->>Logger: update_log_met_request(WardA)
  HRCoordinator->>Logger: update_log_met_assignment(WardA)

  %% After resolution
  WardManager->>Logger: emergency_handled(WardA,PatientX)
