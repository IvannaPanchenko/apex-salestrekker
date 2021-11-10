const COUNTRIES = {
    AUSTRALIA: {
        CODE: 'AU',
        NAME: 'Australia'
    },
    NEW_ZEALAND: {
        CODE: 'NZ',
        NAME: 'New Zealand'
    },
    OTHER: {
        CODE: 'OC',
        NAME: 'Other Countries'
    }
}

function contentType(xhr) {
    return xhr.headers.get('content-type') || '';
}
  
function isJson(xhr) {
    return contentType(xhr).includes('json');
}
  
function parse(xhr) {
    if (isJson(xhr)) return xhr.json().catch(() => ({}));
    return xhr.text();
}

const getAddresses = (token, apiURL, qtyRecordsToShow, string, countryToSearch) => {
  return new Promise((resolve, reject) => {
    // call the api
    const par = {
        method: 'GET',
        headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        timeout: 60000,
    };

    let url = `${apiURL}/addresses?q=${string}&count=${qtyRecordsToShow || 5}`;

    // if we have countries
    if (countryToSearch && countryToSearch === COUNTRIES.AUSTRALIA.CODE) {
        url += `&country_code=${countryToSearch}`;
    }

    // Attempt the login to the API
    window.fetch(url, par).then(response => parse(response)).then((data) => {
        if (data.error) reject(data.error_description);
        else resolve(data.addresses);
    }).catch((error) => {
        reject(error);
    });
  });
}

// get the details of a given nz post address id
const getAddressDetails = (token, apiURL, id, country) => {
  return new Promise((resolve, reject) => {
    
    // call the api
    const par = {
        method: 'GET',
        headers: {
            Authorization: `Bearer ${token}`,
            Accept: 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        timeout: 60000,
    };

    // if it's Australia then we have a special api to call
    if (country && country === COUNTRIES.AUSTRALIA.CODE) {
        apiURL = apiURL.replace('international', 'australia');
    }

    // Call the api and get the data for the address
    window.fetch(`${apiURL}/addresses/${id}`, par).then(response => parse(response)).then((data) => {
        if (data.error) reject(data.error_description);
        else {
            // New Zealand / Australia search
            if (data.address) resolve(data.address);
            else {
                // international search
                if (data.result && data.result.address_components) {
                    // initialize variable to return
                    let res = {
                        unit_type: undefined,
                        unit_value: undefined,
                        street_alpha: undefined,
                        street_type: undefined,
                        floor: undefined,
                        street_number: undefined,
                        street: undefined,
                        suburb: undefined,
                        city: undefined,
                        postcode: undefined,
                        country: undefined
                    };
                    
                    data.result.address_components.forEach((el) => {
                        res.unit_type = undefined;
                        res.unit_value = undefined;
                        res.street_alpha = undefined;
                        res.street_type = undefined;
                        
                        // floor
                        if (el.types.indexOf('floor') !== -1) res.floor = el.short_name;
                        
                        // street number
                        if (el.types.indexOf('street_number') !== -1) res.street_number = el.short_name;

                        // street
                        if (el.types.indexOf('route') !== -1) res.street = el.long_name;
                        
                        // suburb
                        if (el.types.indexOf('locality') !== -1 || el.types.indexOf('postal_town') !== -1) res.suburb = el.short_name;

                        // city
                        if (el.types.indexOf('administrative_area_level_1') !== -1) res.city = el.short_name;

                        // postal code
                        if (el.types.indexOf('postal_code') !== -1) res.postcode = el.short_name;

                        // country
                        if (el.types.indexOf('country') !== -1) res.country = el.long_name;
                    });

                    resolve(res);
                }
                else {
                    reject('ERROR while getting data'); 
                }
            }
        }
    }).catch((error) => {
        reject(error);
    });
  });
}

export { COUNTRIES, getAddresses, getAddressDetails };