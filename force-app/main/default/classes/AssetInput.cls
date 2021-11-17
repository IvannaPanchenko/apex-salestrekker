/*************************************************************************************************************
 * @name      AssetInput
 * @author      Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created      5 November 2021
 * @description    Salestrekker Wrapper Class
 * @testClass      N/A
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *         No.    Date      Author          Description
 *         ----  ------------  --------------------  ----------------------------------------------
 * @version    1.0    2021-11-05      Ivanna Panchenko      Creation of the class
 *
**************************************************************************************************************/
public with sharing class AssetInput {
    public AssetTypeInput assetType { get; set; }
    public BankAccountTypeInput bankAccountType { get; set; }
    public PropertyTypeInput propertyType { get; set; }
    public Boolean isActive { get; set; }
    public String name { get; set; }
    public Integer value { get; set; }
    public OwnershipInput ownership { get; set; }
}