/**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description This class is to execute methods dynamically from the LWC
                     validate and getIds are just examples and you can add more or do what ever you want inside this
    *   NOTE:
              * Functions that are called for validationMethod needs to return the text to show in the alert if not valid or null
**/

public with sharing class CongaButtonCallableClass implements Callable {
   // method
    private static String validate(String recordId) {
       return null;
   }

    private static String getIds(String recordId) {
       return recordId;
   }

   // Dispatch methods
   public static Object call(String action, Map<String,Object> args) {
     switch on action {
       when 'validate' {
         return validate((String)args.get('recordId'));
       }
       when 'getIds' {
         return getIds((String)args.get('recordId'));
       }
       when else {
        throw new CongaButtonCallableClass_Exception('Method not implemented');
       }
     }
   }

   public class CongaButtonCallableClass_Exception extends Exception {}
}