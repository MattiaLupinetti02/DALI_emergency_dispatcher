```mermaid

classDiagram
    class SensorAgent {
        +alarm(Ward, Patient, Values)
        +new_emergency(Ward, Patient, Values)
        -new_systolic_pressure(Value)
        -new_HR(Value)
        -new_O2(Value)
        -new_respiratory_rate(Value)
    }

    class WardAgent {
        +set_rrt()
        +decrease_available_equipe()
        +increase_available_equipe()
        +human_resource_request(human_res_map, From)
        +human_resource_lending(human_res_map, From)
        +met_request()
        +emergency_handled(Ward, Patient)
        +taking_charge_emergency()
        -available_equipe
        -local_staff
    }

    class CoordinatorAgent {
        +human_resource_reply(human_res_map, From)
        +human_resource_request(human_res_map, From)
        +met_assignment(Ward)
        +assign_met()
        +assign_human_resource()
        -human_resource_availability
        -met_status
    }

    class LoggerAgent {
        +update_log_new_emergency(Ward, Patient, Values)
        +update_log_met_request(Ward)
        +update_log_met_assignment(Ward)
        +update_log_emergency_handled(Ward, Patient)
        -event_log
    }

    SensorAgent --> WardAgent : alarm 
    WardAgent --> CoordinatorAgent : human_resource_request / met_request
    CoordinatorAgent --> WardAgent : met_assignment / human_resource_reply
    SensorAgent --> LoggerAgent : new_emergency
    WardAgent --> LoggerAgent : emergency_handled / met_request
    CoordinatorAgent --> LoggerAgent : met_assignment
