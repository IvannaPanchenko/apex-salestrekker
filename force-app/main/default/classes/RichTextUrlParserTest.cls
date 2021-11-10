/**
* @author Ben Edwards (ben@cloudinit.nz)
* @date 14th December 2017
* @description Test class for the RichTextUrlParser
* 
* CHANGE LOG
**/
@isTest
public class RichTextUrlParserTest {
    
    /**
    *    @author Chris Parker (chris@cloudinit.nz)
    *    @description Test the processing of the URL field
    **/
    @isTest
    static void testGetUrlFromField() {

        String theUrl = 'https://testimage.com/myimage.png';

        // Build a test URL field
        String fieldValue = String.format('<img src="{0}" />', new List<String>{theUrl});

        system.assertEquals(theUrl, RichTextUrlParser.getUrlFromField(fieldValue), 'The processed HTML value should be stripped and the URL only remaining.');
    }
}