```mermaid
sequenceDiagram
    autonumber
    participant HealthSensor
    participant WardManager
    participant HRCoordinator
    participant Logger

    %% PHASE 1 - Detection
    HealthSensor->>WardManager: alarm(WardA, PatientX, Values)
    Note right of WardManager: Receives abnormal vital parameter alert

    HealthSensor->>Logger: new_emergency(WardA, PatientX, Values)
    Logger-->>HealthSensor: acknowledgment

    %% PHASE 2 - Resource Assessment
    alt insufficient staff
        WardManager->>HRCoordinator: human_resource_request(human_res_map, WardA)
        HRCoordinator-->>WardManager: human_resource_reply(human_res_map, WardA)
        WardManager->>WardManager: increase_available_equipe(human_resources_map)
    end

    
    %% PHASE 3 - Local Response
    WardManager->>WardManager: set_rrt
    WardManager->>WardManager: deacrease_available_equipe(human_resources_map)
    Note right of WardManager: Defines RRT and updates local equipe status

    %% PHASE 4 - Critical Emergency → MET Request
    alt critical emergency
        WardManager->>HRCoordinator: met_request
        HRCoordinator->>HRCoordinator: assign_met
        HRCoordinator-->>WardManager: met_assignment(WardA)
        HRCoordinator->>Logger: update_log_met_assignment(WardA)
    end

    %% PHASE 5 - Emergency Taken in Charge
    WardManager->>HealthSensor: taking_charge_emergency
    Note right of HealthSensor: Stops repeated alarms
    WardManager->>Logger: update_log_met_request(WardA)

    %% PHASE 6 - Resolution
    WardManager->>HRCoordinator: emergency_handled(WardA, PatientX)
    WardManager->>Logger: update_log_emergency_handled(WardA, PatientX)

    %% PHASE 7 - Finalization
    HRCoordinator-->>Logger: update_log_met_assignment(WardA)
    Logger-->>All: Log persistence complete
