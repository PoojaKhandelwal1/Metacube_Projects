@isTest
private class PaginationSortingTest {

    static testMethod void TestPaginationSortingAndSortAttrs() {
        PaginationSorting pageSort1 = new PaginationSorting();
        pageSort1.CurrentPage = 1;
        pageSort1.PageSize = 10;
        pageSort1.Sorting = new List <PaginationSorting.SortAttrs> {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        PaginationSorting pageSort2 = new PaginationSorting();
        pageSort2.CurrentPage = 1;
        pageSort2.PageSize = 10;
        pageSort2.Sorting = new List <PaginationSorting.SortAttrs> {
            new PaginationSorting.SortAttrs('Item', 'ASC','Id')
        };
        
        PaginationSorting pageSortAttrs = PaginationSorting.parsePageAttrs(System.JSON.serialize(pageSort1));
        system.assertEquals(1,pageSortAttrs.CurrentPage);
    }
}