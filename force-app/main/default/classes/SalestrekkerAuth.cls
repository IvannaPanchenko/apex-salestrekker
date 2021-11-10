/*************************************************************************************************************
 * @name			SalestrekkerAuth
 * @author			James Winter <james@beintelligent.nz>
 * @created			13th September 2021
 * @description		Helper Class to build GraphQL payloads for Salestrekker
 * @testClass       SalestrekkerAuthTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-13      James Winter			Creation of the class
 *
**************************************************************************************************************/
public with sharing class SalestrekkerAuth {

    public static String createAuthPayload() {
        //Mutation Query
        GraphQLNode node = new GraphQLNode('Authenticate')
                .setOperation('mutation')
                .addArguments(new GraphQLArgument('$apiKey', 'String!', true))
                .add(
                        new GraphQLNode('authenticate')
                                .addArguments(new GraphQLArgument[]{
                                new GraphQLArgument('apiKey', '$apiKey', true)
                        })
                        .add(new Object[]{'token', 'code', 'isFirstLogin'})
                );
        Authenticate authenticate = new Authenticate();
        authenticate.apiKey = '{!$Credential.Password}';

        //Create GraphQLQuery with Variables
        GraphQLQuery qry = new GraphQLQuery(node, authenticate);
        String payload = JSON.serialize(qry);
        System.debug('############# payload '+payload);
        return payload;
    }

    //Auth Variable DTOs
    public class Authenticate {
        public String apiKey { get; set; }
    }

}