/*************************************************************************************************************
 * @name      OwnershipInput
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
public with sharing class OwnershipInput {
    public String idContact { get; set; }
    public Integer percent { get; set; }
    public Boolean isActive { get; set; }
}