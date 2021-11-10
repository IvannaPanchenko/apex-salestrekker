/**
* @author Pablo Martinez (pablomartinez@cdeloitte.co.nz)
* @date 16/09/2019
* @description
*
**/
@IsTest
public with sharing class EnhancedRelatedListQueryAbstractTest extends EnhancedRelatedListQueryAbstract {
    public override List<Object> getObjects() {
        Id contactId = getRecordId();
        List<Case> cases = [SELECT Subject FROM Case WHERE ContactId = :contactId LIMIT 1];
        List<String> result = new List<String>();
        for (Case ct : cases) {
            result.add(ct.Subject);
        }
        return result;
    }
}