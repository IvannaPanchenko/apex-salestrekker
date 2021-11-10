/*************************************************************************************************************
 * @name			SalestrekkerNote
 * @author			Ivanna Panchenko
 * @created			28th October 2021
 * @description		Helper Class to build GraphQL payloads for Salestrekker
 * @testClass       SalestrekkerNoteTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-28      Ivanna Panchenko		Creation of the class
 *
**************************************************************************************************************/
public with sharing class SalestrekkerNote {
  
    public static String createNotePayload(CreateNote noteDetails) {

        //Mutation Query
        GraphQLNode node = new GraphQLNode('CreateNote')
                .setOperation('mutation')
                .addArguments(new GraphQLArgument('$note', 'NoteInput!', true))
                .add(
                        new GraphQLNode('noteCreate')
                                .addArguments(new GraphQLArgument[]{
                                new GraphQLArgument('note', '$note', true)
                        })
                );

        //Create GraphQLQuery with Variables
        GraphQLQuery qry = new GraphQLQuery(node, noteDetails);
        String payload = JSON.serialize(qry);
        System.debug('########## Create note '+payload);
        return payload;
    }

   
    //Ticket Variable DTOs
    public class CreateNote {
        public Note note { get; set; }

        public CreateNote(){
            this.note = new Note();
        }
    }

    public class Note {
        public String idOwner { get; set; }
        public Boolean isActive { get; set; }
        public String idWorkflow { get; set; }
        public String idTicket { get; set; }
        public String content { get; set; }
        public NoteTypeEnumerator type {get;set;}
        public List<string> idLabels { get; set; }
    }

}