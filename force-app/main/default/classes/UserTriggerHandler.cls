public with sharing class UserTriggerHandler extends TriggerHandler {

    // The list of Rich Text to URL fields to process
    // Add the API name of the Rich Text field on the left, and the URL field it should copy to on the right
    public static Map<String, String> processRichTextFields = new Map<String, String>{
        'Signature_Image__c' => 'Signature_Image_Url__c'
   };

    // Handle all Before Insert actions
    public override void beforeInsert() {

        parseDrawingImageUrl();
    }
    
    // Handle all Before Update actions
    public override void beforeUpdate() {

        parseDrawingImageUrl();
    }

    /**
    *    @description Takes an image from a rich text field and creates the URL for the image
    *                 The image is then used to merge into Conga documents.
    **/
    public void parseDrawingImageUrl() {

        // Iterate over the Users
        for (User userVar :(List<User>) Trigger.new) {

            // Get the old User record
            User olduserVar = Trigger.oldMap != null ? (User) Trigger.oldMap.get(userVar.Id) : null;

            // Iterate over the rich text fields to process
            for (String richTextField :processRichTextFields.keyset()) {

                // Get the name of the URL field
                String urlField = processRichTextFields.get(richTextField);

                // If the rich text field is blank, clear the URL field
                if (userVar.get(richTextField) == null) {

                    // Clear the URL value
                    userVar.put(urlField, null);
                }
                else {

                    try {

                        // Get the rich text value from the field
                        String richTextValue = String.valueOf(userVar.get(richTextField));
                    
                        // Process the Rich TExt and put the URL in the URL field
                        userVar.put(urlField, RichTextUrlParser.getUrlFromField(richTextValue));
                    }
                    catch (Exception ex) {

                        system.debug('### Could not process image from rich text for field ' + richTextField + ': ' + ex.getMessage() + '\n\n' + ex.getStackTraceString());
                    }
                }
            }
        }
    }

}