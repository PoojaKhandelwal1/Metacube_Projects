/**
 * Author: Tarun Khandelwal
 * Since: August 17, 2018
 * Name: FusionBenchmarkingWrapper
 * Description: Wrapper class for Fusion Benchmarking Object
**/
public without sharing class FusionBenchmarkingWrapper {
    
    public String Id;
    public String SelectedMonth;
    public String SelectedYear;
    public Decimal AverageTechnicianPrimeLaborCost;
    public Decimal EmployeeNoAdministrationAndOther;
    public Decimal EmployeeNoParts;
    public Decimal EmployeeNoSales;
    public Decimal EmployeeNoServiceNonTechnical;
    public Decimal EmployeeNoServiceTechnical;
    public Decimal NoSalesPeople;
    public Decimal WorkingDaysInPeriod;
    public Decimal NoOfWorkingDays;
    public Decimal NoInsuranceContractsWritten;
    
    public FusionBenchmarkingWrapper() {}
    
    public FusionBenchmarkingWrapper(Fusion_Benchmarking__c fusionBenchMarkingRec) {
        this.Id = fusionBenchMarkingRec.Id;
        this.AverageTechnicianPrimeLaborCost = fusionBenchMarkingRec.Average_Technician_Prime_Labor_Cost__c;
        this.EmployeeNoAdministrationAndOther = fusionBenchMarkingRec.Employee_No_Administration_Other__c;
        this.EmployeeNoParts = fusionBenchMarkingRec.Employee_No_Parts__c;
        this.EmployeeNoSales = fusionBenchMarkingRec.Employee_No_Sales__c;
        this.EmployeeNoServiceNonTechnical = fusionBenchMarkingRec.Employee_No_Service_Non_Technical__c;
        this.EmployeeNoServiceTechnical = fusionBenchMarkingRec.Employee_No_Service_Technical__c;
        this.NoSalesPeople = fusionBenchMarkingRec.No_Sales_People__c;
    }
    
    public static List<String> getFusionBenchMarkingFields() {
       return new List<String>{'Average_Technician_Prime_Labor_Cost__c', 
                                'Employee_No_Administration_Other__c', 
                                'Employee_No_Parts__c',
                                'Employee_No_Sales__c', 
                                'Employee_No_Service_Non_Technical__c',
                                'Employee_No_Service_Technical__c',
                                'No_Sales_People__c',
                                'Working_days_in_Period__c',
                                'No_of_Working_Days__c',
                                'No_Insurance_Contracts_Written__c'
                              };
    }
}