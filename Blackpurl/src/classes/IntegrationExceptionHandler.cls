public with sharing class IntegrationExceptionHandler {
    public String entityName;
    public IntegrationExceptionHandler(String entityName) {
        this.entityName = entityName;
    }
    public void handleException(String exceptionType, List<Object> failedEntitites) {
        //use case statement and handle error for each type of exception
    }
}