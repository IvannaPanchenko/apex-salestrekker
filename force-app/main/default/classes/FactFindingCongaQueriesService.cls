/**
* @author Patrick Lorilla (plorilla@cdeloitte.co.nz)
* @date 1/03/2021
* @description Class with method to select the conga query Id based on the conga query name
* @Modification Log
* 
**/

public without sharing class FactFindingCongaQueriesService {

    public static Map<String, String> congaQueryIdsByName{
        
        get{

            if(congaQueryIdsByName == null ){

                congaQueryIdsByName = new Map<String,String>();

                for(APXTConga4__Conga_Merge_Query__c cquery : [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c LIKE 'Fact Find - %' OR APXTConga4__Name__c  = 'Opportunity Application Roles' LIMIT 50]){

                    congaQueryIdsByName.put(cquery.APXTConga4__Name__c, cquery.Id);

                }

            }

            return congaQueryIdsByName;

        }
        set;
    }

    public String othentities{

        get{

            if(String.isBlank(othentities)){

                othentities = congaQueryIdsByName.get('Fact Find - Other Entities');
            }

            return othentities;
        }
        set;
    }

    public String employment{

        get{

            if(String.isBlank(employment)){

                employment = congaQueryIdsByName.get('Fact Find - Employment Details');
            }

            return employment;
        }
        set;
    }

    public String oppapproles{
        
        get{

            if(String.isBlank(oppapproles)){

                oppapproles = congaQueryIdsByName.get('Opportunity Application Roles'); 

            }

            return oppapproles;

        }
        set;
    }

    public String dependents{
        
        get{

            if(String.isBlank(dependents)){

                dependents = congaQueryIdsByName.get('Fact Find - Dependents');  

            }

            return dependents;

        }
        set;
    }

    public String otherfamily{
        
        get{

            if(String.isBlank(otherfamily)){

                otherfamily = congaQueryIdsByName.get('Fact Find - Other Family');  
            }

            return otherfamily;
        }
        set;
    }

    public String owners{
        
        get{

            if(String.isBlank(owners)){

                owners = congaQueryIdsByName.get('Fact Find - Owners'); 
            }

            return owners;
        }
        set;
    }

    public String incexp{
        
        get{

            if(String.isBlank(incexp)){

                incexp = congaQueryIdsByName.get('Fact Find - Income'); 
            }

            return incexp;
        }
        set;
    }

    public String assets{
        
        get{

            if(String.isBlank(assets)){

                assets = congaQueryIdsByName.get('Fact Find - Assets'); 
            }

            return assets;
        }
        set;
    }

    public String nonapexserviced{
        
        get{

            if(String.isBlank(nonapexserviced)){

                nonapexserviced = congaQueryIdsByName.get('Fact Find - Non Apex Serviced Cover'); 
            }

            return nonapexserviced;
        }
        set;
    }

    public String liability{
        
        get{

            if(String.isBlank(liability)){

                liability = congaQueryIdsByName.get('Fact Find - Liabilities'); 
            }

            return liability;
        }
        set;
    }

    public String expenses{
        
        get{

            if(String.isBlank(expenses)){

                expenses = congaQueryIdsByName.get('Fact Find - Expenses');  
            }

            return expenses;
        }
        set;
    }

    public String analysismed{
        
        get{

            if(String.isBlank(analysismed)){

                analysismed = congaQueryIdsByName.get('Fact Find - Analysis (Medical)'); 
            }

            return analysismed;
        }
        set;
    }

    public String estate{
        
        get{

            if(String.isBlank(estate)){

                estate = congaQueryIdsByName.get('Fact Find - Estate Planning');
            }

            return estate;
        }
        set;
    }

    public String goals{
        
        get{

            if(String.isBlank(goals)){

                goals = congaQueryIdsByName.get('Fact Find - Goals'); 
            }

            return goals;
        }
        set;
    }

    public String invstgoals{
        
        get{

            if(String.isBlank(invstgoals)){

                invstgoals = congaQueryIdsByName.get('Fact Find - Investment Goals');  
            }

            return invstgoals;
        }
        set;
    }

    public String contingent{
        
        get{

            if(String.isBlank(contingent)){

                contingent = congaQueryIdsByName.get('Fact Find - Contingent Liability'); 
            }

            return contingent;
        }
        set;
    }

    public String analysisbills{
        
        get{

            if(String.isBlank(analysisbills)){

                analysisbills = congaQueryIdsByName.get('Fact Find - Analysis (Bills)'); 
            }

            return analysisbills;
        }
        set;
    }

    public String analysistrauma{
        
        get{

            if(String.isBlank(analysistrauma)){

                analysistrauma = congaQueryIdsByName.get('Fact Find - Analysis (Trauma)'); 
            }

            return analysistrauma;
        }
        set;
    }

    public String analysisTPD{
        
        get{

            if(String.isBlank(analysisTPD)){

                analysisTPD = congaQueryIdsByName.get('Fact Find - Analysis (TPD)');  
            }

            return analysisTPD;
        }
        set;
    }

    public String analysisLife{
        
        get{

            if(String.isBlank(analysisLife)){

                analysisLife = congaQueryIdsByName.get('Fact Find - Analysis (Life)');
            }

            return analysisLife;
        }
        set;
    }

     public String disposableasset{
        
        get{

            if(String.isBlank(disposableasset)){

                disposableasset = congaQueryIdsByName.get('Fact Find - Asset Disposable');
            }

            return disposableasset;
        }
        set;
    }

    public String analysisInvst{
        
        get{

            if(String.isBlank(analysisInvst)){

                analysisInvst =  congaQueryIdsByName.get('Fact Find - Analysis (Investment)'); 
            }

            return analysisInvst;
        }
        set;
    }

     public String giftableasset{
        
        get{

            if(String.isBlank(giftableasset)){

                giftableasset = congaQueryIdsByName.get('Fact Find - Asset Giftable'); 
            }

            return giftableasset;
        }
        set;
    }

    public String analysissurvey{
        
        get{

            if(String.isBlank(analysissurvey)){

                analysissurvey = congaQueryIdsByName.get('Fact Find - Analysis Survey');  
            }

            return analysissurvey;
        }
        set;
    }

    public String referral{
        
        get{

            if(String.isBlank(referral)){

                referral = congaQueryIdsByName.get('Fact Find - Referrals'); 
            }

            return referral;
        }
        set;
    }

    public String acctcontact{
        
        get{

            if(String.isBlank(acctcontact)){

                acctcontact = congaQueryIdsByName.get('Fact Find - Related Contacts'); 
            }

            return acctcontact;
        }
        set;
    }

    public String understanding{
        
        get{

            if(String.isBlank(understanding)){

                understanding = congaQueryIdsByName.get('Fact Find - Understanding You As Investor');  
            }

            return understanding;
        }
        set;
    }

    public String factfind{
        
        get{

            if(String.isBlank(factfind)){

                factfind = congaQueryIdsByName.get('Fact Find - Fact Find');  
            }

            return factfind;
        }
        set;
    }


    public String medissues{
        
        get{

            if(String.isBlank(medissues)){

                medissues = congaQueryIdsByName.get('Fact Find - Analysis (Medical Issues)'); 
            }

            return medissues;
        }
        set;
    }

     public String sig{
        
        get{

            if(String.isBlank(sig)){

                sig = congaQueryIdsByName.get('Fact Find - Signatures'); 
            }

            return sig;
        }
        set;
    }






}