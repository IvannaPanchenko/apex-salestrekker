/*************************************************************************************************************
 * @name      LiabilityInput
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
public with sharing class LiabilityInput {
    public LiabilityTypeInput liabilityType { get; set; }
    public Boolean mortgageType { get; set; }
    public Boolean isActive { get; set; }
    public String name { get; set; }
    public String lenderOtherName { get; set; } // salesforce Liability Id
    public Integer balance { get; set; }
    public OwnershipInput ownership { get; set; }
    public Long fixedExpiryDate { get; set; }
    public Long endDate { get; set; }
}

