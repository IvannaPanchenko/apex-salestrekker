public class OpenUrl {

    public String Page {get; set;}
    public String OpenPageURL {get; set;}
    
    public void OpenURL()
    {
        Page = '' ;
        OpenPageURL = '' ;
    }
    
    public PageReference redirect()
    {
        if(Page == 'google')
        {
            //OpenPageURL = '<a target="_blank" href="http://www.google.co.in/'" rel="nofollow">http://www.google.co.in/'</a> ;
            //OpenPageURL = '<a target="test" href="http://www.google.com"</a>' ;
        }
        return null;
    }


}