@IsTest
private class GoogleGeocodeTests {

    private class GoogleMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"OK","results":[{"formatted_address":"Feira de Santana - BA, Brasil","geometry":{"location":{"lat":-12.2664,"lng":-38.9663}}}]}');
            return res;
        }
    }

    @IsTest static void testLeadGeocodeSuccess() {
        Test.setMock(HttpCalloutMock.class, new GoogleMock());

        Lead l = new Lead(
            LastName='Teste',
            Company='Acme',
            Street='Centro',
            City='Feira de Santana',
            State='BA',
            PostalCode='44000-000',
            Country='Brasil'
        );

        Test.startTest();
        insert l;
        Test.stopTest();

        Lead reloaded = [
            SELECT Geo_Status__c, Geo_Lat__c, Geo_Lng__c, Geo_Formatted_Address__c, Geo_LastError__c
            FROM Lead
            WHERE Id = :l.Id
        ];

        System.assertEquals('Success', reloaded.Geo_Status__c);
        System.assertNotEquals(null, reloaded.Geo_Lat__c);
        System.assertNotEquals(null, reloaded.Geo_Lng__c);
        System.assertNotEquals(null, reloaded.Geo_Formatted_Address__c);
        System.assertEquals(null, reloaded.Geo_LastError__c);
    }

    @IsTest static void testMissingAddressGivesError() {
        Test.setMock(HttpCalloutMock.class, new GoogleMock());

        Lead l = new Lead(LastName='Teste', Company='Acme');

        Test.startTest();
        insert l;
        Test.stopTest();

        Lead reloaded = [SELECT Geo_Status__c, Geo_LastError__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals('Error', reloaded.Geo_Status__c);
        System.assertNotEquals(null, reloaded.Geo_LastError__c);
    }
}
