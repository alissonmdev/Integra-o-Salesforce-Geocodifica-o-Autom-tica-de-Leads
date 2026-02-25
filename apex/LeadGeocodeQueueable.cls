public with sharing class LeadGeocodeQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> leadIds;

    public LeadGeocodeQueueable(Set<Id> leadIds) {
        this.leadIds = (leadIds == null) ? new Set<Id>() : leadIds;
    }

    public void execute(QueueableContext context) {
        if (leadIds.isEmpty()) return;

        List<Lead> leads = [
            SELECT Id,
                   Street, City, State, PostalCode, Country,
                   Geo_Status__c, Geo_LastError__c, Geo_Formatted_Address__c, Geo_Lat__c, Geo_Lng__c
            FROM Lead
            WHERE Id IN :leadIds
        ];

        List<Lead> updates = new List<Lead>();

        for (Lead l : leads) {
            String fullAddress = buildAddress(l);

            if (String.isBlank(fullAddress)) {
                updates.add(new Lead(
                    Id = l.Id,
                    Geo_Status__c = 'Error',
                    Geo_LastError__c = 'Endereço incompleto: preencha rua/cidade/estado/país.'
                ));
                continue;
            }

            try {
                GoogleGeocodeService.GeocodeResult r = GoogleGeocodeService.geocodeAddress(fullAddress);

                if (r != null && r.status == 'Success') {
                    updates.add(new Lead(
                        Id = l.Id,
                        Geo_Status__c = 'Success',
                        Geo_Lat__c = r.lat,
                        Geo_Lng__c = r.lng,
                        Geo_Formatted_Address__c = r.formattedAddress,
                        Geo_LastError__c = null
                    ));
                } else {
                    updates.add(new Lead(
                        Id = l.Id,
                        Geo_Status__c = 'Error',
                        Geo_LastError__c = (r == null) ? 'Resposta nula do serviço de geocode.' : r.errorMessage
                    ));
                }
            } catch (Exception e) {
                updates.add(new Lead(
                    Id = l.Id,
                    Geo_Status__c = 'Error',
                    Geo_LastError__c = e.getMessage()
                ));
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }

    private static String buildAddress(Lead l) {
        List<String> parts = new List<String>();

        if (!String.isBlank(l.Street))     parts.add(l.Street);
        if (!String.isBlank(l.City))       parts.add(l.City);
        if (!String.isBlank(l.State))      parts.add(l.State);
        if (!String.isBlank(l.PostalCode)) parts.add(l.PostalCode);
        if (!String.isBlank(l.Country))    parts.add(l.Country);

        return String.join(parts, ', ').trim();
    }
}
