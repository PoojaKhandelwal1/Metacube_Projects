public class BRPVehicleResponseWrapper {

    public ShowVehicleSpecifications ShowVehicleSpecifications;
    
    public class ShowVehicleSpecifications {
        public ShowVehicleSpecificationsDataArea ShowVehicleSpecificationsDataArea;
    }
    
    public class ShowVehicleSpecificationsDataArea {
        public VehicleSpecifications VehicleSpecifications;
    }
    
    public class VehicleSpecifications {
        public VehicleSpecificationsLine VehicleSpecificationsLine;
    }
    
    public class VehicleSpecificationsLine {
        public Vehicle Vehicle;
    }
    
    public class Vehicle {
        public String VehicleDescription;
        public String ModelGroup;
        public String ManufacturerName;
        public String VehicleID;
        public Engine Engine;
        public String ModelDescription;
        public String ModelYear;
        public String Model;
    }
    
    public class Engine {
        public String DisplacementMeasure;
        public String NumberOfEngineCylindersNumeric;
    }
}