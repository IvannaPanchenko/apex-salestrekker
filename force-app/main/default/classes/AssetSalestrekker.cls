/*************************************************************************************************************
 * @name      AssetSalestrekker
 * @author      Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created      12 November 2021
 * @description    Salestrekker Wrapper Class
 * @testClass      N/A
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *         No.    Date      Author          Description
 *         ----  ------------  --------------------  ----------------------------------------------
 * @version    1.0    2021-11-12      Ivanna Panchenko      Creation of the class
 *
**************************************************************************************************************/
public with sharing class AssetSalestrekker {
    public String name { get; set; }
    public String id { get; set; }
    public String bankBsb { get; set;} // will represent the SF assets Id 
    public Integer value { get; set; }
    public Boolean isActive { get; set; }
    public Ownership[] ownership { get; set; }
    public AssetType assetType { get; set; }
    public PropertyType propertyType { get; set; }
    public BankAccountType bankAccountType { get; set;}
 
    public class Ownership {
        public String idContact;
    }

    public class AssetType{
        public AssetTypeEnumerator name { get; set; }
    }

    public class PropertyType {

        public PropertyTypeEnumerator name { get; set; }
    }

    public class BankAccountType{
        public BankAccountTypeEnumerator name { get; set; }
    }

}