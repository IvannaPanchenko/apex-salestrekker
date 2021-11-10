/**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description This class is to use inside LWC, the callMethod is a method to dynamically call the Callable class
**/

public with sharing class CongaButtonController {
    
    @AuraEnabled(cacheable=true)
    public static String getApiURL() {
      return URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId();
    }
    
    @AuraEnabled
    public static String callMethod(String className, String methodName, String recordId){
      Callable classToCall = (Callable) Type.forName(className).newInstance();
      String result = (String) classToCall.call(methodName, new Map<String, Object> { 'recordId' => recordId });

      return result;
    }
}