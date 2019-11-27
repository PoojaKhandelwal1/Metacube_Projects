/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */
/**
 * VF Page: CustomLookupClassicPage.page
 * Description: Custom lookup controller for Salesforce Classic using AngularJS
 * author: Gaurav Saini (6 Jan, 2018) for REF-1238
 */
public with sharing class CustomLookupClassicController {
    public String searchText { get; set; }
    public String namespace { get; set; }

    public CustomLookupClassicController() {
        namespace = UtilityController.appNamespace();
        searchText = ApexPages.currentPage().getParameters().get('searchText') != null
                        ? ApexPages.currentPage().getParameters().get('searchText') : '';
    }

    /**
     * method to get list of users based on search text
     * author: Gaurav Saini (9 Jan, 2018) REF-1238
     */
    @RemoteAction
    public static String getItemWrapperList(String searchText) {
        List<ItemWrapper> itemsList = new List<ItemWrapper>();
        String communityProfileName = '\'%Community%\'';
        String siteProfileName = '\'%Guest%\'';
        String queryString = '';
        
        if (searchText != null && searchText.trim().length() > 0) {
            String searchValue = searchText.replace('*', '%') + '%';
            searchValue = String.escapeSingleQuotes(searchValue);
            searchValue = '\'%' + searchValue + '\'';
            queryString = 'SELECT Id, Name FROM User '
                            + 'WHERE IsActive = true '
                            + 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
                            + 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
                            + 'AND (NOT Name LIKE ' + siteProfileName + ') '
                            + 'AND (Name LIKE ' + searchValue + ') ORDER BY Name LIMIT 50';
        } else {
            queryString = 'SELECT Id, Name FROM User '
                            + 'WHERE IsActive = true '
                            + 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
                            + 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
                            + 'AND (NOT Name LIKE ' + siteProfileName + ') '
                            + 'ORDER BY Name LIMIT 50';
        }
        
        for (Sobject sObj : Database.query(queryString)) {
            itemsList.add(new ItemWrapper(String.valueOf(sObj.get('Id')), String.valueOf(sObj.get('Name'))));
        }
        return JSON.serialize(itemsList);
    }

    /**
     * method to get list of users based on search text
     * author: Gaurav Saini (9 Jan, 2018) REF-1238
     */
    @RemoteAction
    public static String getMoreItems(String searchText, String alreadyPresentIdsJson) {
        List<ItemWrapper> itemsList = new List<ItemWrapper>();
        String communityProfileName = '\'%Community%\'';
        String siteProfileName = '\'%Guest%\'';
        List<String> alreadyPresentIds = (List<String>)JSON.deserialize(alreadyPresentIdsJson, List<String>.class);
        String queryString = '';
        
        if (searchText != null && searchText.trim().length() > 0) {
            String searchValue = searchText.replace('*', '%') + '%';
            searchValue = String.escapeSingleQuotes(searchValue);
            String searchValueNext = '\'% ' + searchValue + '\'';
            searchValue = '\'' + searchValue + '\'';
            queryString = 'SELECT Id, Name FROM User '
                            + 'WHERE IsActive = true '
                            + 'AND Id NOT IN :alreadyPresentIds '
                            + 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
                            + 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
                            + 'AND (NOT Name LIKE ' + siteProfileName + ') '
                            + 'AND (Name LIKE ' + searchValue + ' '
                            + 'OR Name LIKE ' + searchValueNext + ') ORDER BY Name LIMIT 50';
        } else {
            queryString = 'SELECT Id, Name FROM User '
                            + 'WHERE IsActive = true '
                            + 'AND Id NOT IN :alreadyPresentIds '
                            + 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
                            + 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
                            + 'AND (NOT Name LIKE ' + siteProfileName + ') '
                            + 'ORDER BY Name LIMIT 50';
        }
        
        for (Sobject sObj : Database.query(queryString)) {
            itemsList.add(new ItemWrapper(String.valueOf(sObj.get('Id')), String.valueOf(sObj.get('Name'))));
        }
        return JSON.serialize(itemsList);
    }

    public class ItemWrapper {
        public String id { get; set; }
        public String name { get; set; }

        public ItemWrapper(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }
}