```mermaid
flowchart TD
    A([Start]) --> B[Receive alarm from SensorAgent]
    B --> C{Equipe available?}
    C -- Yes --> D[set_rrt()]
    D --> E[taking_charge_emergency()]
    C -- No --> F[human_resource_request(human_res_map, Ward)]
    F --> G{Emergency critical?}
    G -- Yes --> H[met_request()]
    G -- No --> I[Skip MET request]
    H --> J[Handle emergency]
    I --> J
    J --> K[emergency_handled(Ward, Patient)]
    K --> L[update_log_emergency_handled → Logger]
    L --> M([End])
