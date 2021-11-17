/*************************************************************************************************************
 * @name			SalestrekkerTicket
 * @author			James Winter <james@beintelligent.nz>
 * @created			13th September 2021
 * @description		Helper Class to build GraphQL payloads for Salestrekker
 * @testClass       SalestrekkerTicketTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-13      James Winter			Creation of the class
 *
**************************************************************************************************************/
public with sharing class SalestrekkerTicket {

    public static String queryTicketPayload(String ticketId) {
        GraphQLNode node = new GraphQLNode('ticket')
                .addArguments(new GraphQLArgument('id', ticketId))
                .add(new Object[] { 'id', 'idOwner', 'isActive', 'timeStamp',
                        'ref', 'uuid', 'idWorkflow', 'idStage', 'idClients', 'idLabels', 'name', 'description',
                        new GraphQLNode('values')
                        .add(new Object[]{ 'onceOff' }),
                        new GraphQLNode('ticketClientTypes')
                                .add(new Object[]{ 'idContact', 'idLabel' }),
                        new GraphQLNode('assets')
                                .add(new Object[]{ 'id', 'name','isActive','value', 
                                        new GraphQLNode('ownership')
                                        .add(new Object[]{ 'idContact' }),
                                        new GraphQLNode('assetType')
                                        .add(new Object[]{ 'name' }),
                                        new GraphQLNode('bankAccountType')
                                        .add(new Object[]{ 'name' }),
                                        new GraphQLNode('propertyType')
                                        .add(new Object[]{ 'name' })})
                      
                });

        // create GraphQLQuery without Variables
        GraphQLQuery qry = new GraphQLQuery(node, null);
        String payload = JSON.serialize(qry);
        System.debug('################# queryTicketPayload'+payload);
        return payload;
    }

    public static String createTicketPayload(CreateTicket ticketDetails) {

        //Mutation Query
        GraphQLNode node = new GraphQLNode('CreateTicket')
                .setOperation('mutation')
                .addArguments(new GraphQLArgument('$ticket', 'TicketInput!', true))
                .add(
                        new GraphQLNode('ticketCreate')
                                .addArguments(new GraphQLArgument[]{
                                new GraphQLArgument('ticket', '$ticket', true)
                        })
                );

        //Create GraphQLQuery with Variables
        GraphQLQuery qry = new GraphQLQuery(node, ticketDetails);
        String payload = JSON.serialize(qry);
        System.debug(payload);
        return payload;
    }

    public static String updateTicketPayload(UpdateTicket ticketDetails) {

        //Mutation Query
        GraphQLNode node = new GraphQLNode('UpdateTicket')
                .setOperation('mutation')
                .addArguments(new GraphQLArgument('$id', 'ID!', true))
                .addArguments(new GraphQLArgument('$ticket', 'TicketInput!', true))
                .add(
                    new GraphQLNode('ticketUpdate')
                    .addArguments(new GraphQLArgument[]{
                      new GraphQLArgument('id', '$id', true),
                      new GraphQLArgument('ticket', '$ticket', true)
                    }));
              

        //Create GraphQLQuery with Variables
        GraphQLQuery qry = new GraphQLQuery(node, ticketDetails);
        String payload = JSON.serialize(qry);
        System.debug('######### updateTicketPayload ' + payload);
        return payload;
    }

    public class TopTicket {
        public Data data;
    }
    
    public class Data {
        public Ticket ticket;
    }

    //Ticket Variable DTOs
    public class CreateTicket {
        public InputTicket ticket { get; set; }
    }

    //Ticket Variable DTOs
    public class UpdateTicket {
        public String id { get; set; }
        public InputTicket ticket { get; set; }
    }

    public class Ticket {
        public String id { get; set; }
        public String idOwner { get; set; }
        public Boolean isActive { get; set; }
        public String idWorkflow { get; set; }
        public String idStage { get; set; }
        public String[] idClients { get; set; }
        public String[] idLabels { get; set; }
        public String [] idContacts { get; set; }
        public String name { get; set; }
        public String description { get; set; }
        public Values values { get; set; }
        public TicketClientTypes[] ticketClientTypes { get; set; }
        public AssetSalestrekker[] assets { get; set; }
        
    }


    public class InputTicket {
        public String idOwner { get; set; }
        public Boolean isActive { get; set; }
        public String idWorkflow { get; set; }
        public String idStage { get; set; }
        public Boolean isSettled {get; set;}
        public Boolean isWon {get; set;} 
        public Boolean isLost {get; set;} 
        public String[] idClients { get; set; }
        public TicketClientTypes[] ticketClientTypes { get; set; }
        public String [] idContacts { get; set; }
        public String name { get; set; }
        public Values values { get; set; }
        public Long wonTimeStamp { get; set; }
        public Long lostTimeStamp { get; set; }
        public Boolean isInProgress { get; set; }
        public String description { get; set; }
        public AssetInput[] assets { get; set; }
    }

    public class TicketClientTypes {
        public String idContact { get; set; }
        public String idLabel { get; set; }
    }

    public class TicketContactTypes {
        public Integer idContact { get; set; }
        //public Integer idLabel { get; set; }
    }
    public class Values {
        public Decimal onceOff { get; set; }
    }

}