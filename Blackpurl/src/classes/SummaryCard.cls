/**
 * Author: Richa Mittal
 * Since: July 11, 2017
 * Name: SummaryCard
 * Description: Class is used for the Creation of the Json for home page widgets
**/
public with sharing class SummaryCard {

    public String Name; 
    public String BlockColor;
    public String IconName;
    public Integer OrderNumber;
    public List<SummaryBlock> BlockList;
    public List<SummaryFilter> FilterList;
    
    /*
     * Name:HomeSearchFilterWrapper
     * Description: Constructor
    **/
    public SummaryCard(Summary_Card__mdt summaryCardWithAllFilters, String ApplicationImagesPath, String filterValue) {
        this.Name = summaryCardWithAllFilters.Label;
        this.BlockColor = summaryCardWithAllFilters.Block_Color__c;
        this.IconName = ApplicationImagesPath + '/Icons/' + summaryCardWithAllFilters.Icon_Class__c;
        this.OrderNumber = Integer.valueOf(summaryCardWithAllFilters.Order_Number__c);
        
        this.BlockList = new List<SummaryBlock>();
        this.FilterList = new List<SummaryFilter>();
        
        Map<Integer, String> filterOrderNumberToNameMap = new Map<Integer, String>();
        for(Summary_Block__mdt block: summaryCardWithAllFilters.Summary_Blocks__r) {
            if(block.Filter_Value__c == filterValue) {
                SummaryBlock blockObj = new SummaryBlock(block);
                this.BlockList.add(blockObj);
            }
            
            if(block.Filter_Value__c != null) {
                if(!filterOrderNumberToNameMap.containsKey(Integer.valueOf(block.Filter_Order_Number__c))) {
                    filterOrderNumberToNameMap.put(Integer.valueOf(block.Filter_Order_Number__c), block.Filter_Value__c);
                }
            }
        }
        
        for(Integer orderNumber: FilterOrderNumberToNameMap.keySet()) {
            SummaryFilter f = new SummaryFilter(orderNumber, FilterOrderNumberToNameMap.get(orderNumber));
            this.FilterList.add(f);
        }
        
    }
    
    public class SummaryFilter {

        public String Name;
        public Integer FilterOrderNumber;
        
        /*
         * Name:SummaryBlock
         * Description: Constructor
        **/
        public SummaryFilter(Integer filterOrderNumber, String name) {
            this.Name = name;
            this.FilterOrderNumber = filterOrderNumber;
        }
    }
    
    public class SummaryBlock {

        public String Name; 
        public Integer Value;
        public String Type;
        public String FilterName; 
        public Integer OrderNumber;
        public Integer FilterOrderNumber;
        public String HomeSearchFilterJson;
        public String HomeSearchAdditionalFieldJson;
        
        /*
         * Name:SummaryBlock
         * Description: Constructor
        **/
        public SummaryBlock(Summary_Block__mdt block) {
            this.Name = block.Block_Name__c;
            this.Type = block.Data_Type__c;
            this.FilterName = block.Filter_Value__c;
            this.OrderNumber = Integer.valueOf(block.Order_Number__c);
            this.FilterOrderNumber = Integer.valueOf(block.Filter_Order_Number__c);
            this.Value = 0;
            this.HomeSearchFilterJson = block.Home_Search_Filter_Json__c;
            this.HomeSearchAdditionalFieldJson = block.Home_Search_Additional_Field_Json__c;
            
            String query = BPUtility.escapeSingleQuotes(block.Query__c);
            Decimal resultTotal = 0;
            if(query != null)   {
                for(String q : query.split(';'))    {
                    if(block.Order_Number__c == 2) {
                        //system.assert(false, q);
                    }
                    q = q.replace('\r\n', '').replace('\n', '').replace('\r', '').replace('\\', '');
                    AggregateResult[] queryResult = Database.query(q);
                    Decimal res = (Decimal)queryResult[0].get('expr0');
                    if(res == null) {
                        res = 0;
                    }
                    resultTotal += res;
                }
                resultTotal = resultTotal.setScale(0);
            }
            this.Value = Integer.valueOf(resultTotal);
        }
        
    }
    
    public static List<String> summaryCardFieldsList(){
        List<String> CardFieldsList = new List<String>{ 'Id',
                                                        'Label',
                                                        'DeveloperName',
                                                        'Block_Color__c',
                                                        'Icon_Class__c',
                                                        'Order_Number__c',
                                                        'Active__c'
                                                };
        return CardFieldsList;
    }
    
    public static List<String> summaryBlockFieldsList(){
        List<String> BlockFieldsList = new List<String>{ 'Id',
                                                        'Label',
                                                        'DeveloperName',
                                                        'Active__c',
                                                        'Block_Name__c',
                                                        'Data_Type__c',
                                                        'Filter_Value__c',
                                                        'Order_Number__c',
                                                        'Query__c',
                                                        'Summary_Card__c',
                                                        'Filter_Order_Number__c',
                                                        'Home_Search_Filter_Json__c',
                                                        'Home_Search_Additional_Field_Json__c'
                                                };
        return BlockFieldsList;
    }
}