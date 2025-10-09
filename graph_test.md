```mermaid


graph TD
    %%=== Agents / Roles ===
    HS[HealthSensor]
    WM1[WardManager (Requester)]
    WM2[WardManager (Lender)]
    HRC[HRCoordinator]
    LOG[Logger]

    subgraph Role_HealthSensor [HealthSensor Role Schema]
        HS_DESC["Detects abnormal vital parameters and triggers alarm(Ward,Patient,Values)"]
        HS -->|alarm(Ward,Patient,Values)| WM1
        HS -->|new_emergency(Ward,Patient,Values)| LOG
        WM1 -->|taking_charge_emergency| HS
    end

    subgraph Role_WardManager [WardManager Role Schema]
        WM_DESC["Handles alarms, sets RRT, manages equipe, requests HR or MET via HRCoordinator"]
        WM1 -->|human_resource_request(human_res_map,WardA)| HRC
        HRC -->|human_resource_request(human_res_map,From=WardA)| WM2
        WM2 -->|human_resource_lending(human_res_map,From=WardB)| HRC
        HRC -->|human_resource_reply(human_res_map,From=WardB)| WM1
        WM1 -->|met_request(WardA,PatientX)| HRC
        HRC -->|met_assignment(WardA)| WM1
        WM1 -->|emergency_handled(WardA,PatientX)| LOG
        WM1 -->|human_resource_restitution(WardB,human_res_map)| HRC
    end

    subgraph Role_HRCoordinator [HRCoordinator Role Schema]
        HRC_DESC["Broker for HR exchange and MET dispatcher. No own resources."]
        HRC -->|forward human_resource_request| WM2
        WM2 -->|human_resource_lending| HRC
        HRC -->|aggregate → human_resource_reply| WM1
        HRC -->|assign_met / met_assignment| WM1
        HRC -->|update_log_met_assignment| LOG
    end

    subgraph Role_Logger [Logger Role Schema]
        LOG_DESC["Stores persistent timestamped logs for all events"]
        HS -->|new_emergency| LOG
        WM1 -->|update_log_emergency_handled| LOG
        HRC -->|update_log_met_assignment| LOG
    end

    %%=== Style and hierarchy ===
    classDef role fill:#dff0d8,stroke:#333,stroke-width:1px,color:#000;
    classDef agent fill:#d0e8f2,stroke:#333,stroke-width:1px,color:#000;
    class HS,WM1,WM2,HRC,LOG agent;
    class Role_HealthSensor,Role_WardManager,Role_HRCoordinator,Role_Logger role;
