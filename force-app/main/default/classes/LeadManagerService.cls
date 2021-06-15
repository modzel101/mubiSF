@RestResource(urlMapping='/MubiService')
global with sharing class LeadManagerService {
    private static final String ERROR_MESSAGE_REQUIRED_FIELD_MISSING = 'Required fields missing';
    private static final String SUCCESS_MESSAGE_CREATED = 'Created';
    private static final String SUCCESS_MESSAGE_UPDATED = 'Updated';
    private static final String LEAD_COMPANY_NOT_PROVIDED = 'Not Provided';
    private static final String LEAD_STATUS_OPEN_NOT_CONTRACTED = 'Open - Not Contracted';
    
    @HttpPut
    global static void upsertLeads() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;

        List<LeadDsr> deserializedLeads = (List<LeadDsr>) JSON.deserialize(request.requestBody.toString(), List<LeadDsr>.class);
        List<LeadResponse> responseList = new List<LeadResponse>();

        List<Lead> leadsToUpsert = new List<Lead>();
        for (LeadDsr leadDsr : deserializedLeads) {
            Lead l = createLead(leadDsr);
            if (validateLead(l)) {
                leadsToUpsert.add(l);
            } else {
                LeadResponse lr = new LeadResponse(l.External_Id__c);
                lr.success = false;
                lr.message = ERROR_MESSAGE_REQUIRED_FIELD_MISSING;
                responseList.add(lr);
            }
        }
        List<Database.UpsertResult> results = Database.upsert(leadsToUpsert, Lead.External_Id__c, false);
        for (Database.UpsertResult result : results) {
            LeadResponse lr = new LeadResponse(result.getId());
            lr.success = result.isSuccess();
            lr.message = generateMessage(result);
            responseList.add(lr);
        }
        res.responseBody = Blob.valueOf(JSON.serialize(responseList));
    }

    private static Lead createLead(LeadManagerService.LeadDsr leadDsr) {
        return new Lead(
                Company = LEAD_COMPANY_NOT_PROVIDED,
                Status = LEAD_STATUS_OPEN_NOT_CONTRACTED,
                FirstName = leadDsr.firstname,
                LastName = leadDsr.lastname,
                Phone = leadDsr.phone,
                Created_Date_External__c = Datetime.valueOf(leadDsr.createddate.replace('T', ' ')),
                External_Id__c = leadDsr.id,
                Street = leadDsr.address.street,
                City = leadDsr.address.city,
                Country = leadDsr.address.country,
                PostalCode = leadDsr.address.postalcode
        );
    }

    private static String generateMessage(Database.UpsertResult result) {
        String message;
        if (result.isSuccess()) {
            message = result.isCreated() ? SUCCESS_MESSAGE_CREATED : SUCCESS_MESSAGE_UPDATED;
        } else {
            message = handleErrors(result);
        }
        return message;
    }

    private static Boolean validateLead(Lead l) {
        if (l.Phone == null || l.External_Id__c == null || l.LastName == null) {
            return false;
        } else {
            return true;
        }
    }

    private static String handleErrors(Database.UpsertResult result) {
        String message = 'Errors: \n';
        if (!result.getErrors().isEmpty()) {
            for (Database.Error err : result.getErrors()) {
                message += err.getFields() + ' ' + err.getMessage() + '\n';
            }
        }
        return message;
    }

    private class LeadDsr {
        String id;
        String createddate;
        String firstname;
        String lastname;
        String phone;
        Address address;

    }
    private class Address {
        String street;
        String city;
        String postalcode;
        String country;
    }

    public class LeadResponse {
        String id;
        Boolean success;
        String message;
        private LeadResponse(String id) {
            this.id = id;
        }
    }
}