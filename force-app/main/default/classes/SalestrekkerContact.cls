/*************************************************************************************************************
 * @name			SalestrekkerContact
 * @author			James Winter <james@beintelligent.nz>
 * @created			13th September 2021
 * @description		Helper Class to build GraphQL payloads for Salestrekker
 * @testClass       SalestrekkerContactTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-13      James Winter			Creation of the class
 *
**************************************************************************************************************/
public with sharing class SalestrekkerContact {

    public static String queryContactPayload(String contactId) {
        GraphQLNode node = new GraphQLNode('contact')
                .addArguments(new GraphQLArgument('id', contactId))
                .add(new Object[] { 'id', 'idOwner', 'description',
                        new GraphQLNode('person').add(new Object[] {
                                new GraphQLNode ('information')
                                        .add(new Object[]{ 'firstName', 'familyName' })
                        })
                });

        // create GraphQLQuery without Variables
        GraphQLQuery qry = new GraphQLQuery(node, null);
        String payload = JSON.serialize(qry);
        System.debug(payload);
        return payload;
    }

    public static String createContactPayload(CreateContact contactDetails) {

        //Mutation Query
        GraphQLNode node = new GraphQLNode('CreateContact')
                .setOperation('mutation')
                .addArguments(new GraphQLArgument('$contact', 'ContactInput!', true))
                .add(
                        new GraphQLNode('contactCreate')
                                .addArguments(new GraphQLArgument[]{
                                new GraphQLArgument('contact', '$contact', true)
                        })
                );

        //Create GraphQLQuery with Variables
        GraphQLQuery qry = new GraphQLQuery(node, contactDetails);
        String payload = JSON.serialize(qry,true);
        System.debug(payload);
        return payload;
    }


    public class TopContact {
        public Data data;
    }

    public class Data {
        public ContactInput contact;
    }

    //Contact Variable DTOs
    public class CreateContact {
        public ContactInput contact { get; set; }
    }

    public class ContactInput {
       // public String id { get; set; }
        public String idOwner { get; set; }
        public Boolean isActive {get; set; }
        public List<string> idLabels { get; set; }
        public String description { get; set; }
        public Person person { get; set; }
    }

    public class Person {
        public ContactPersonInformationInput  information  { get; set; }
        public ContactPersonInput contact { get; set; }
    }

    public class ContactPersonInformationInput {
        public String firstName { get; set; }
        public String familyName { get; set; }
        public String preferredName {get; set;}
        public Long dateOfBirth {get;set;}
        //public String gender {get; set;}
    }

    public class ContactPersonInput {
        public String email { get; set; }
        
    }
}