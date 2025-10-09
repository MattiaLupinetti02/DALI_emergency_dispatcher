```mermaid

graph TD

HS["HealthSensor"]
WM1["WardManager Requester"]
WM2["WardManager Lender"]
HRC["HRCoordinator"]
LOG["Logger"]

HS -->|alarm to Ward| WM1
HS -->|report new emergency| LOG
WM1 -->|acknowledge emergency| HS

WM1 -->|request human resources| HRC
WM1 -->|restitution human resources| HRC
HRC -->|restitution human resource to the lender ward| WM2
HRC -->|forward request to other ward| WM2
WM2 -->|lend human resources| HRC
HRC -->|reply with available staff| WM1

WM1 -->|request MET support| HRC
HRC -->|assign MET to ward| WM1

WM1 -->|log handled emergency| LOG
WM1 -->|return borrowed staff| HRC

HRC -->|notify MET assignment| LOG
HS -->|log new emergency| LOG
WM1 -->|log emergency handled| LOG
HRC -->|log resource dispatch| LOG
