/*************************************************************************************************************
 * @name      LiabilitySalestrekker
 * @author      Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created      18 November 2021
 * @description    Salestrekker Wrapper Class
 * @testClass      N/A
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *         No.    Date      Author          Description
 *         ----  ------------  --------------------  ----------------------------------------------
 * @version    1.0    2021-11-18      Ivanna Panchenko      Creation of the class
 *
**************************************************************************************************************/
public with sharing class LiabilitySalestrekker {
    public String name { get; set; }
    public String id { get; set; }
    public Integer balance { get; set; }
    public Boolean isActive { get; set; }
    public Boolean mortgageType { get; set; }
    public String lenderOtherName { get; set; } 
    public String fixedExpiryDate { get; set; } 
    public String endDate { get; set; } 
    public Ownership[] ownership { get; set; }
    public LiabilityType liabilityType { get; set; }

    

    public class Ownership {
        public String idContact;
    }

    public class LiabilityType{
        public LiabilityTypeEnumerator name { get; set; }
    }

}
