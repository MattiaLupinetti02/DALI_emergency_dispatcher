```mermaid
flowchart TD
    A([Start]) --> B[Receive alarm from SensorAgent]
    B --> C{Equipe available?}
    C -->|Yes| D[Set RRT]
    D --> K[Emergengy handled]
    D --> E[Taking charge of emergency]
    C -->|No| F[Human resource request]
    F --> G{Emergency critical?}
    G -->|Yes| H[MET request]
    G -->|No| I[Skip MET request]
    H --> J[Handle emergency]
    I --> J
    J --> K[Emergency handled]
    K --> L[Update log on Logger]
    L --> M([End])

