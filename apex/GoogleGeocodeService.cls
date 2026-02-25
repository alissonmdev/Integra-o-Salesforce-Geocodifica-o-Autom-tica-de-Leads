public with sharing class GoogleGeocodeService {
    public class GeocodeResult {
        public Decimal lat;
        public Decimal lng;
        public String formattedAddress;
        public String status; // Success/Error
        public String errorMessage;
    }

    public static GeocodeResult geocodeAddress(String fullAddress) {
        GeocodeResult result = new GeocodeResult();

        Google_Settings__mdt cfg = Google_Settings__mdt.getInstance('Default');
        if (cfg == null || !cfg.IsEnabled__c || String.isBlank(cfg.ApiKey__c)) {
            result.status = 'Error';
            result.errorMessage = 'Geocoding desativado ou API Key ausente no Custom Metadata.';
            return result;
        }

        String encoded = EncodingUtil.urlEncode(fullAddress, 'UTF-8');
        String path = '/maps/api/geocode/json?address=' + encoded + '&key=' + cfg.ApiKey__c;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:GoogleGeocode' + path);
        req.setTimeout(20000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            result.status = 'Error';
            result.errorMessage = 'HTTP ' + res.getStatusCode() + ' - ' + safeTrim(res.getBody(), 1000);
            return result;
        }

        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String apiStatus = (String) payload.get('status');

        if (apiStatus != 'OK') {
            result.status = 'Error';
            result.errorMessage = 'Google status: ' + apiStatus;
            return result;
        }

        List<Object> results = (List<Object>) payload.get('results');
        if (results == null || results.isEmpty()) {
            result.status = 'Error';
            result.errorMessage = 'Google retornou OK, mas sem resultados.';
            return result;
        }

        Map<String, Object> first = (Map<String, Object>) results[0];
        result.formattedAddress = (String) first.get('formatted_address');

        Map<String, Object> geometry = (Map<String, Object>) first.get('geometry');
        Map<String, Object> location = (Map<String, Object>) geometry.get('location');

        result.lat = (Decimal) location.get('lat');
        result.lng = (Decimal) location.get('lng');

        result.status = 'Success';
        return result;
    }

    private static String safeTrim(String s, Integer maxLen) {
        if (s == null) return null;
        return (s.length() > maxLen) ? s.substring(0, maxLen) : s;
    }
}
