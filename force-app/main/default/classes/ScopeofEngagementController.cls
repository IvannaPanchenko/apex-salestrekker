/**
* @author David Catindoy (david@cloudinit.nz)
* @date Oct 17, 2017
* @description Controller for Scope of Engagement page
*
* CHANGE LOG
**/
public with sharing class ScopeofEngagementController {
    
    //Public variables
    public String recordId {get; set;}
    public Boolean refreshRecord {get; set;}
    
    public Services service {
        get {
            if(service == null){
                service = new Services();
            }
            return service;
        }
        set;
    }
    
    public ProductProviders provider {
        get {
            if(provider == null){
                provider = new ProductProviders();
            }
            return provider;
        }
        set;
    }
    
    public Benefits benefit {
        get {
            if(benefit == null){
                benefit = new Benefits();
            }
            return benefit;
        }
        set;
    }
    
    //Controller
    public ScopeofEngagementController(ApexPages.StandardController stdController){
        recordId = stdController.getId();
        initialize();
    }
    
    // Method to untick all checkboxes
    public void untickAll() {
        service = null;
        provider = null;
        benefit = null;
    }
    
    public void initialize(){
        service = null;
        provider = null;
        benefit = null;
        try{
            Opportunity opp = [SELECT Id, Services__c, Risk_Providers__c, Kiwisaver_Providers__c, Investment_Providers__c, Mortgage_Providers__c, Benefits__c FROM Opportunity WHERE Id = :recordId];
            
            if(String.isNotBlank(opp.Services__c)){
                service.riskManagement = opp.Services__c.contains('Personal Risk Management');
                service.businessInsurance = opp.Services__c.contains('Business Insurance');
                service.healthInsurance = opp.Services__c.contains('Health Insurance');
                service.investmentPlanning = opp.Services__c.contains('Investment Planning');
                service.retirementPlanning = opp.Services__c.contains('Retirement Planning');
                service.kiwiSaver = opp.Services__c.contains('Kiwisaver');
                service.mortgage = opp.Services__c.contains('Mortgage');
                service.financialCoachingAdvice = opp.Services__c.contains('Financial Coaching/Advice');
            }
            
            if(String.isNotBlank(opp.Risk_Providers__c)){
                provider.riskSouthernCross = opp.Risk_Providers__c.contains('Southern Cross');
                provider.amp = opp.Risk_Providers__c.contains('AMP');
                provider.aia = opp.Risk_Providers__c.contains('AIA');
                provider.asteron = opp.Risk_Providers__c.contains('Asteron');
                provider.fidelity = opp.Risk_Providers__c.contains('Fidelity');
                provider.cigna = opp.Risk_Providers__c.contains('Cigna');
                provider.nib = opp.Risk_Providers__c.contains('NIB');
                provider.partnersLife = opp.Risk_Providers__c.contains('Partners Life');
            }
            
            if(String.isNotBlank(opp.Kiwisaver_Providers__c)){
                provider.oneAnswer = opp.Kiwisaver_Providers__c.contains('OneAnswer');
                provider.booster = opp.Kiwisaver_Providers__c.contains('Booster');
                provider.fisherFunds = opp.Kiwisaver_Providers__c.contains('Fisher Funds');
                provider.generate = opp.Kiwisaver_Providers__c.contains('Generate');
                provider.aon = opp.Kiwisaver_Providers__c.contains('AON');
                provider.other = opp.Kiwisaver_Providers__c.contains('Other');
            }
            
            if(String.isNotBlank(opp.Investment_Providers__c)){
                provider.swm = opp.Investment_Providers__c.contains('Select Wealth Management');
                provider.iSelect = opp.Investment_Providers__c.contains('iSelect');
                provider.synergy = opp.Investment_Providers__c.contains('Synergy');
                provider.consilium = opp.Investment_Providers__c.contains('Consilium');
            }
            
            if(String.isNotBlank(opp.Mortgage_Providers__c)){
                provider.mortgageSovereign = opp.Mortgage_Providers__c.contains('Sovereign');
                provider.asb = opp.Mortgage_Providers__c.contains('ASB');
                provider.cooperativeBank = opp.Mortgage_Providers__c.contains('Co-Operative Bank');
                provider.westpac = opp.Mortgage_Providers__c.contains('Westpac');
                provider.tsb = opp.Mortgage_Providers__c.contains('TSB');
                provider.liberty = opp.Mortgage_Providers__c.contains('Liberty Financial');
                provider.anz = opp.Mortgage_Providers__c.contains('ANZ');
                provider.bnz = opp.Mortgage_Providers__c.contains('BNZ');
                provider.resimac = opp.Mortgage_Providers__c.contains('Resimac');
                provider.sbs = opp.Mortgage_Providers__c.contains('SBS');
            }
            
            if(String.isNotBlank(opp.Benefits__c)){
                benefit.lifeCover = opp.Benefits__c.contains('Life Cover');
                benefit.traumaCover = opp.Benefits__c.contains('Trauma Cover');
                benefit.tpd = opp.Benefits__c.contains('Total Permanent Disablement');
                benefit.incomeProtection = opp.Benefits__c.contains('Income Protection');
                benefit.mortgageProtection = opp.Benefits__c.contains('Mortgage Protection');
                benefit.healthInsurance = opp.Benefits__c.contains('Health Insurance');
                benefit.wop = opp.Benefits__c.contains('Waiver of Premium');
                benefit.aic = opp.Benefits__c.contains('Accidental Injury Cover');
                benefit.redundancyCvr = opp.Benefits__c.contains('Redundancy Cover');
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    //Method to save all changes in the scope of engagement page/component
    public void saveRecord(){
        refreshRecord = false;
        
        Set<String> services = new Set<String>{service.riskManagement ? 'Personal Risk Management' : 'N/A', service.businessInsurance ? 'Business Insurance' : 'N/A',
                                               service.healthInsurance ? 'Health Insurance' : 'N/A', service.investmentPlanning ? 'Investment Planning' : 'N/A',
                                               service.retirementPlanning ? 'Retirement Planning' : 'N/A', service.kiwiSaver ? 'Kiwisaver' : 'N/A',
                                               service.mortgage ? 'Mortgage' : 'N/A', service.financialCoachingAdvice ? 'Financial Coaching/Advice' : 'N/A'};
        if(services.contains('N/A')){
            services.remove('N/A');
        }
        
        Set<String> riskProviders = new Set<String>{provider.riskSouthernCross ? 'Southern Cross' : 'N/A', provider.amp ? 'AMP' : 'N/A', provider.aia ? 'AIA' : 'N/A', provider.asteron ? 'Asteron' : 'N/A',
                                                    provider.fidelity ? 'Fidelity' : 'N/A', provider.cigna ? 'Cigna' : 'N/A', provider.nib ? 'NIB' : 'N/A', provider.partnersLife ? 'Partners Life' : 'N/A'};
        if(riskProviders.contains('N/A')){
            riskProviders.remove('N/A');
        }
        
        Set<String> kiwiSaver = new Set<String>{provider.oneAnswer ? 'OneAnswer' : 'N/A', provider.booster ? 'Booster' : 'N/A', provider.fisherFunds ? 'Fisher Funds' : 'N/A',
                                                provider.generate ? 'Generate' : 'N/A', provider.aon ? 'AON' : 'N/A', provider.other ? 'Other' : 'N/A'};
        if(kiwiSaver.contains('N/A')){
            kiwiSaver.remove('N/A');
        }
        
        Set<String> investment = new Set<String>{provider.swm ? 'Select Wealth Management' : 'N/A', provider.iSelect ? 'iSelect' : 'N/A',
                                                 provider.synergy ? 'Synergy' : 'N/A', provider.consilium ? 'Consilium' : 'N/A'};
        if(investment.contains('N/A')){
            investment.remove('N/A');
        }
        
        Set<String> mortgage = new Set<String>{provider.mortgageSovereign ? 'Sovereign' : 'N/A', provider.asb ? 'ASB' : 'N/A', provider.cooperativeBank ? 'Co-Operative Bank' : 'N/A',
                                               provider.westpac ? 'Westpac' : 'N/A', provider.tsb ? 'TSB' : 'N/A', provider.liberty ? 'Liberty Financial' : 'N/A',
                                               provider.anz ? 'ANZ' : 'N/A', provider.bnz ? 'BNZ' : 'N/A', provider.resimac ? 'Resimac' : 'N/A', provider.sbs ? 'SBS' : 'N/A'};
        if(mortgage.contains('N/A')){
            mortgage.remove('N/A');
        }
        
        Set<String> benefits = new Set<String>{benefit.lifeCover ? 'Life Cover' : 'N/A', benefit.traumaCover ? 'Trauma Cover' : 'N/A', benefit.tpd ? 'Total Permanent Disablement' : 'N/A',
                                               benefit.incomeProtection ? 'Income Protection' : 'N/A', benefit.mortgageProtection ? 'Mortgage Protection' : 'N/A',
                                               benefit.healthInsurance ? 'Health Insurance' : 'N/A', benefit.wop ? 'Waiver of Premium' : 'N/A', benefit.aic ? 'Accidental Injury Cover' : 'N/A', benefit.redundancyCvr ? 'Redundancy Cover' : 'N/A'};
        if(benefits.contains('N/A')){
            benefits.remove('N/A');
        }
        
        try{
            Opportunity opp = new Opportunity(Id = recordId, Services__c = String.join(new List<String>(services), ';'), Risk_Providers__c = String.join(new List<String>(riskProviders), ';'),
                                              Kiwisaver_Providers__c = String.join(new List<String>(kiwiSaver), ';'), Investment_Providers__c = String.join(new List<String>(investment), ';'),
                                              Mortgage_Providers__c = String.join(new List<String>(mortgage), ';'), Benefits__c = String.join(new List<String>(benefits), ';'));
            Database.update(opp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Scope of Engagement successfully saved.'));
            refreshRecord = true;
            initialize();
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        getAllPageMessagesMap();
    }
    
    //Wrapper classes
    public class Services {
        public Boolean riskManagement {get; set;}
        public Boolean businessInsurance {get; set;}
        public Boolean healthInsurance {get; set;}
        public Boolean investmentPlanning {get; set;}
        public Boolean retirementPlanning {get; set;}
        public Boolean kiwiSaver {get; set;}
        public Boolean mortgage {get; set;}
        public Boolean financialCoachingAdvice {get;set;}
    }
    
    public class ProductProviders {
        public Boolean riskSouthernCross {get; set;}
        public Boolean amp {get; set;}
        public Boolean aia {get; set;}
        public Boolean asteron {get; set;}
        public Boolean fidelity {get; set;}
        public Boolean cigna {get; set;}
        public Boolean nib {get; set;}
        public Boolean partnersLife {get; set;}
        public Boolean oneAnswer {get; set;}
        public Boolean booster {get; set;}
        public Boolean fisherFunds {get; set;}
        public Boolean generate {get; set;}
        public Boolean aon {get; set;}
        public Boolean other {get; set;}
        public Boolean swm {get; set;}
        public Boolean iSelect {get; set;}
        public Boolean synergy {get; set;}
        public Boolean consilium {get; set;}
        public Boolean mortgageSovereign {get; set;}
        public Boolean asb {get; set;}
        public Boolean cooperativeBank {get; set;}
        public Boolean westpac {get; set;}
        public Boolean tsb {get; set;}
        public Boolean liberty {get; set;}
        public Boolean anz {get; set;}
        public Boolean bnz {get; set;}
        public Boolean resimac {get; set;}
        public Boolean sbs {get; set;}
    }
    
    public class Benefits {
        public Boolean lifeCover {get; set;}
        public Boolean traumaCover {get; set;}
        public Boolean tpd {get; set;}
        public Boolean incomeProtection {get; set;}
        public Boolean mortgageProtection {get; set;}
        public Boolean healthInsurance {get; set;}
        public Boolean wop {get; set;}
        public Boolean aic {get; set;}
        public Boolean redundancyCvr{get; set;}
    }
    
    public Map<String, List<String>> getAllPageMessagesMap() {

        Map<String, List<String>> allPageMessagesMap = new Map<String, List<String>>();

        // Iterate over each alert message
        for(ApexPages.Message apexPageMessage : ApexPages.getMessages()) {

            // Get the alert style for the message
            String alertTheme = ApexAkina_Constants.severityToThemeMap.get(apexPageMessage.getSeverity());

            // If the map already contains an error for this style
            if (allPageMessagesMap.containsKey(alertTheme)) {

                // Get the existing list
                List<String> existingErrors = allPageMessagesMap.get(alertTheme);

                // Add the new error
                existingErrors.add(apexPageMessage.getDetail());

                // Put back into the map
                allPageMessagesMap.put(alertTheme, existingErrors);
            } else {
                // Otherwise, it doesn't yet exist
                allPageMessagesMap.put(alertTheme, new List<String>{apexPageMessage.getDetail()});
            }
        }
        return allPageMessagesMap;
    }

}