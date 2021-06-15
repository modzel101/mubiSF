@RestResource(urlMapping='/MubiService')
global with sharing class LeadManagerService {
    @HttpPut
    global static String upsertLeads() {
        RestRequest request = RestContext.request;

        List<Object> requestBody = (List<Object>) JSON.deserializeUntyped(request.requestBody.toString());
        System.debug(requestBody);
        List<Lead> leadsToUpsert = new List<Lead>();
        for(Object o : requestBody){    
            Map<String,Object> data = (Map<String,Object>)o;
            
            Lead l = new Lead();
            String dtStr = (String) data.get('createddate');
            Datetime dt = Datetime.valueOf(dtStr.replace('T', ' '));
            l.put('Company', 'Not Provided');
            l.put('Status', 'Open - Not Contracted');
            l.put('FirstName', data.get('firstname'));
            l.put('LastName', data.get('lastname'));
            l.put('Created_Date_External__c', dt);
            l.put('Phone', data.get('phone'));
            l.put('External_Id__c', data.get('id'));
            leadsToUpsert.add(l);
        }
        upsert leadsToUpsert External_Id__c;

        return 'co tam';
    }

    private class LeadsResponse {
        String id;
        Boolean success;
        String message;
        
        private LeadsResponse(String id, Boolean success, String message) {
            this.id = id;
            this.success = success;
            this.message = message;
        } 
    }
}