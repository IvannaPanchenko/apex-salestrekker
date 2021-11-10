/**
* @author Chris Parker (chris@cloudinit.nz)
* @date 14th December 2017
* @description Take a rich text field and parse the URL from it. Used for Conga Documents
* 
* CHANGE LOG
**/
public with sharing class RichTextUrlParser {
  
    /**
    *    @author Chris Parker (chris@cloudinit.nz)
    *    @description Take the content of a rich text field and parse the URL.
    **/
    public static String getUrlFromField (String fieldValue) {

        // Parse the img src from the rich text HTML
        String firstSubString = fieldValue.substringBetween('<img', '/>');

        // If blank, attempt using a different closing tag
        // As Salesforce does something funky with the closing tag
        if (String.isBlank(firstSubString)) {

            firstSubString = fieldValue.substringBetween('<img', '></img>');
        }

        String secondSubString = firstSubString.substringBetween('src="', '"');
        String imageUrl = secondSubString.replace('&amp;', '&');

        return imageUrl;
    }  
}