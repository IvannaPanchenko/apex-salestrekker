/*************************************************************************************************************
 * @name      HouseholdExpenseInput
 * @author      Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created      23 November 2021
 * @description    Salestrekker Wrapper Class
 * @testClass      N/A
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *         No.    Date      Author          Description
 *         ----  ------------  --------------------  ----------------------------------------------
 * @version    1.0    2021-11-23      Ivanna Panchenko      Creation of the class
 *
**************************************************************************************************************/

public with sharing class HouseholdExpenseInput {
   public HouseholdExpenseTypeInput type { get; set; }
   public Integer value { get; set; }
   public String comments { get; set; }
   // public PaymentFrequencyInput  frequency { get; set; }
}
