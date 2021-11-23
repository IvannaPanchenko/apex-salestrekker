/*************************************************************************************************************
 * @name			DateUtils
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			19 November 2021
 * @description		To return Date operations
 * @testClass       DateUtils todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-11-19      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
public without sharing class DateUtils {


    public static Datetime getDateTimeFromADate ( Date dateT){
        Integer d = dateT.day();
        Integer mo = dateT.month();
        Integer yr = dateT.year();
        
        DateTime DT = DateTime.newInstance(yr, mo, d);
        Long ldate = DT.getTime();
        return Datetime.newInstance(lDate);
    }


    public static Long getEpochFromDate(Date dateT){

        Datetime dateTimeF = DateUtils.getDateTimeFromADate(dateT);
        return dateTimeF.getTime() / 1000;
    }

}