import Foundation

class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    // MARK: - Location to Country Code Mapping
    private let locationToCountryCode: [String: String] = [
        // Africa
        "nigeria": "NG", "ghana": "GH", "kenya": "KE", "south africa": "ZA", "ethiopia": "ET",
        "egypt": "EG", "morocco": "MA", "tunisia": "TN", "algeria": "DZ", "libya": "LY",
        "sudan": "SD", "south sudan": "SS", "chad": "TD", "niger": "NE", "mali": "ML",
        "burkina faso": "BF", "senegal": "SN", "gambia": "GM", "guinea-bissau": "GW", "guinea": "GN",
        "sierra leone": "SL", "liberia": "LR", "ivory coast": "CI", "togo": "TG", "benin": "BJ",
        "cameroon": "CM", "central african republic": "CF", "equatorial guinea": "GQ", "gabon": "GA",
        "congo": "CG", "democratic republic of congo": "CD", "angola": "AO", "zambia": "ZM",
        "zimbabwe": "ZW", "botswana": "BW", "namibia": "NA", "mozambique": "MZ", "malawi": "MW",
        "tanzania": "TZ", "uganda": "UG", "rwanda": "RW", "burundi": "BI", "djibouti": "DJ",
        "somalia": "SO", "eritrea": "ER", "comoros": "KM", "madagascar": "MG", "mauritius": "MU",
        "seychelles": "SC", "cape verde": "CV", "sao tome and principe": "ST",
        
        // Asia
        "china": "CN", "japan": "JP", "korea": "KR", "india": "IN", "pakistan": "PK",
        "bangladesh": "BD", "sri lanka": "LK", "nepal": "NP", "bhutan": "BT", "myanmar": "MM",
        "thailand": "TH", "laos": "LA", "vietnam": "VN", "cambodia": "KH", "malaysia": "MY",
        "singapore": "SG", "indonesia": "ID", "philippines": "PH", "brunei": "BN", "east timor": "TL",
        "mongolia": "MN", "kazakhstan": "KZ", "kyrgyzstan": "KG", "tajikistan": "TJ", "uzbekistan": "UZ",
        "turkmenistan": "TM", "afghanistan": "AF", "iran": "IR", "iraq": "IQ", "syria": "SY",
        "lebanon": "LB", "jordan": "JO", "israel": "IL", "palestine": "PS", "saudi arabia": "SA",
        "yemen": "YE", "oman": "OM", "uae": "AE", "qatar": "QA", "kuwait": "KW", "bahrain": "BH",
        
        // Europe
        "united kingdom": "GB", "france": "FR", "germany": "DE", "italy": "IT", "spain": "ES",
        "portugal": "PT", "netherlands": "NL", "belgium": "BE", "luxembourg": "LU", "switzerland": "CH",
        "austria": "AT", "poland": "PL", "czech republic": "CZ", "slovakia": "SK", "hungary": "HU",
        "romania": "RO", "bulgaria": "BG", "greece": "GR", "albania": "AL", "macedonia": "MK",
        "serbia": "RS", "croatia": "HR", "slovenia": "SI", "bosnia and herzegovina": "BA", "montenegro": "ME",
        "kosovo": "XK", "ukraine": "UA", "belarus": "BY", "moldova": "MD", "russia": "RU",
        "estonia": "EE", "latvia": "LV", "lithuania": "LT", "finland": "FI", "sweden": "SE",
        "norway": "NO", "denmark": "DK", "iceland": "IS", "ireland": "IE", "malta": "MT",
        "cyprus": "CY", "turkey": "TR", "georgia": "GE", "armenia": "AM", "azerbaijan": "AZ",
        
        // North America
        "united states": "US", "canada": "CA", "mexico": "MX", "cuba": "CU", "jamaica": "JM",
        "haiti": "HT", "dominican republic": "DO", "puerto rico": "PR", "bahamas": "BS", "barbados": "BB",
        "trinidad and tobago": "TT", "grenada": "GD", "saint lucia": "LC", "saint vincent and the grenadines": "VC",
        "antigua and barbuda": "AG", "dominica": "DM", "saint kitts and nevis": "KN", "belize": "BZ",
        "guatemala": "GT", "el salvador": "SV", "honduras": "HN", "nicaragua": "NI", "costa rica": "CR",
        "panama": "PA",
        
        // South America
        "brazil": "BR", "argentina": "AR", "chile": "CL", "peru": "PE", "colombia": "CO",
        "venezuela": "VE", "ecuador": "EC", "bolivia": "BO", "paraguay": "PY", "uruguay": "UY",
        "guyana": "GY", "suriname": "SR", "french guiana": "GF",
        
        // Oceania
        "australia": "AU", "new zealand": "NZ", "papua new guinea": "PG", "fiji": "FJ",
        "solomon islands": "SB", "vanuatu": "VU", "new caledonia": "NC", "french polynesia": "PF",
        "samoa": "WS", "tonga": "TO", "micronesia": "FM", "palau": "PW", "marshall islands": "MH",
        "kiribati": "KI", "tuvalu": "TV", "nauru": "NR"
    ]
    
    // MARK: - Language to Country Code Mapping
    private let languageToCountryCode: [String: [String]] = [
        "english": ["US", "GB", "CA", "AU", "NZ", "IE", "ZA", "IN", "PK", "NG", "KE", "UG", "TZ"],
        "spanish": ["ES", "MX", "AR", "CL", "PE", "CO", "VE", "EC", "BO", "PY", "UY", "GT", "SV", "HN", "NI", "CR", "PA", "CU", "DO", "PR"],
        "french": ["FR", "CA", "BE", "CH", "LU", "MC", "DZ", "MA", "TN", "ML", "BF", "SN", "CI", "TG", "BJ", "CM", "CF", "GQ", "GA", "CG", "CD", "MG", "MU", "SC", "CV", "ST", "DJ", "KM", "NC", "PF"],
        "german": ["DE", "AT", "CH", "LU", "LI"],
        "italian": ["IT", "CH", "SM", "VA"],
        "portuguese": ["PT", "BR", "AO", "MZ", "GW", "CV", "ST", "TL"],
        "russian": ["RU", "BY", "KZ", "KG", "TJ", "UZ", "TM", "MD", "GE", "AM", "AZ"],
        "chinese": ["CN", "TW", "HK", "MO", "SG"],
        "japanese": ["JP"],
        "korean": ["KR", "KP"],
        "arabic": ["SA", "EG", "IQ", "SY", "JO", "LB", "PS", "YE", "OM", "AE", "QA", "KW", "BH", "LY", "SD", "TD", "DZ", "MA", "TN", "DJ", "KM", "SO", "ER"],
        "hindi": ["IN", "NP", "FJ"],
        "bengali": ["BD", "IN"],
        "urdu": ["PK", "IN"],
        "turkish": ["TR", "CY"],
        "dutch": ["NL", "BE", "SR"],
        "swedish": ["SE", "FI"],
        "norwegian": ["NO"],
        "danish": ["DK", "GL"],
        "finnish": ["FI"],
        "polish": ["PL"],
        "czech": ["CZ"],
        "hungarian": ["HU"],
        "romanian": ["RO", "MD"],
        "bulgarian": ["BG"],
        "greek": ["GR", "CY"],
        "hebrew": ["IL"],
        "thai": ["TH"],
        "vietnamese": ["VN"],
        "indonesian": ["ID"],
        "malay": ["MY", "BN", "SG"],
        "filipino": ["PH"],
        "swahili": ["TZ", "KE", "UG", "RW", "BI", "CD", "MZ", "MW", "ZM", "ZW"],
        "yoruba": ["NG", "BJ", "TG"],
        "igbo": ["NG"],
        "hausa": ["NG", "NE", "GH", "CM", "TD", "SD"],
        "amharic": ["ET"],
        "somali": ["SO", "ET", "KE", "DJ"],
        "zulu": ["ZA"],
        "xhosa": ["ZA"],
        "afrikaans": ["ZA", "NA"]
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get the best localized name for a herb based on user's location and languages
    func getLocalizedName(for herb: Herb, userLocation: String, userLanguages: [String]) -> String {
        // First, try to find a name based on user's location
        if let locationBasedName = getLocationBasedName(for: herb, userLocation: userLocation) {
            return locationBasedName
        }
        
        // Then, try to find a name based on user's languages
        if let languageBasedName = getLanguageBasedName(for: herb, userLanguages: userLanguages) {
            return languageBasedName
        }
        
        // Fall back to English name
        return herb.englishName
    }
    
    /// Get a localized name based on user's location
    private func getLocationBasedName(for herb: Herb, userLocation: String) -> String? {
        let location = userLocation.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try exact match first
        if let countryCode = locationToCountryCode[location],
           let localName = herb.localNames[countryCode] {
            return localName
        }
        
        // Try partial matches (e.g., "lagos, nigeria" should match "nigeria")
        for (locationKey, countryCode) in locationToCountryCode {
            if location.contains(locationKey) || locationKey.contains(location) {
                if let localName = herb.localNames[countryCode] {
                    return localName
                }
            }
        }
        
        return nil
    }
    
    /// Get a localized name based on user's languages
    private func getLanguageBasedName(for herb: Herb, userLanguages: [String]) -> String? {
        for language in userLanguages {
            let languageLower = language.lowercased()
            
            // Get country codes for this language
            if let countryCodes = languageToCountryCode[languageLower] {
                // Try each country code for this language
                for countryCode in countryCodes {
                    if let localName = herb.localNames[countryCode] {
                        return localName
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Get all available local names for a herb
    func getAllLocalNames(for herb: Herb) -> [(countryCode: String, name: String)] {
        return herb.localNames.map { (countryCode: $0.key, name: $0.value) }
            .sorted { $0.countryCode < $1.countryCode }
    }
    
    /// Get country name from country code
    func getCountryName(from countryCode: String) -> String {
        let countryNames: [String: String] = [
            "NG": "Nigeria", "GH": "Ghana", "KE": "Kenya", "ZA": "South Africa", "ET": "Ethiopia",
            "EG": "Egypt", "MA": "Morocco", "TN": "Tunisia", "DZ": "Algeria", "LY": "Libya",
            "SD": "Sudan", "SS": "South Sudan", "TD": "Chad", "NE": "Niger", "ML": "Mali",
            "BF": "Burkina Faso", "SN": "Senegal", "GM": "Gambia", "GW": "Guinea-Bissau", "GN": "Guinea",
            "SL": "Sierra Leone", "LR": "Liberia", "CI": "Ivory Coast", "TG": "Togo", "BJ": "Benin",
            "CM": "Cameroon", "CF": "Central African Republic", "GQ": "Equatorial Guinea", "GA": "Gabon",
            "CG": "Congo", "CD": "Democratic Republic of Congo", "AO": "Angola", "ZM": "Zambia",
            "ZW": "Zimbabwe", "BW": "Botswana", "NA": "Namibia", "MZ": "Mozambique", "MW": "Malawi",
            "TZ": "Tanzania", "UG": "Uganda", "RW": "Rwanda", "BI": "Burundi", "DJ": "Djibouti",
            "SO": "Somalia", "ER": "Eritrea", "KM": "Comoros", "MG": "Madagascar", "MU": "Mauritius",
            "SC": "Seychelles", "CV": "Cape Verde", "ST": "Sao Tome and Principe",
            "CN": "China", "JP": "Japan", "KR": "South Korea", "IN": "India", "PK": "Pakistan",
            "BD": "Bangladesh", "LK": "Sri Lanka", "NP": "Nepal", "BT": "Bhutan", "MM": "Myanmar",
            "TH": "Thailand", "LA": "Laos", "VN": "Vietnam", "KH": "Cambodia", "MY": "Malaysia",
            "SG": "Singapore", "ID": "Indonesia", "PH": "Philippines", "BN": "Brunei", "TL": "East Timor",
            "MN": "Mongolia", "KZ": "Kazakhstan", "KG": "Kyrgyzstan", "TJ": "Tajikistan", "UZ": "Uzbekistan",
            "TM": "Turkmenistan", "AF": "Afghanistan", "IR": "Iran", "IQ": "Iraq", "SY": "Syria",
            "LB": "Lebanon", "JO": "Jordan", "IL": "Israel", "PS": "Palestine", "SA": "Saudi Arabia",
            "YE": "Yemen", "OM": "Oman", "AE": "UAE", "QA": "Qatar", "KW": "Kuwait", "BH": "Bahrain",
            "GB": "United Kingdom", "FR": "France", "DE": "Germany", "IT": "Italy", "ES": "Spain",
            "PT": "Portugal", "NL": "Netherlands", "BE": "Belgium", "LU": "Luxembourg", "CH": "Switzerland",
            "AT": "Austria", "PL": "Poland", "CZ": "Czech Republic", "SK": "Slovakia", "HU": "Hungary",
            "RO": "Romania", "BG": "Bulgaria", "GR": "Greece", "AL": "Albania", "MK": "Macedonia",
            "RS": "Serbia", "HR": "Croatia", "SI": "Slovenia", "BA": "Bosnia and Herzegovina", "ME": "Montenegro",
            "XK": "Kosovo", "UA": "Ukraine", "BY": "Belarus", "MD": "Moldova", "RU": "Russia",
            "EE": "Estonia", "LV": "Latvia", "LT": "Lithuania", "FI": "Finland", "SE": "Sweden",
            "NO": "Norway", "DK": "Denmark", "IS": "Iceland", "IE": "Ireland", "MT": "Malta",
            "CY": "Cyprus", "TR": "Turkey", "GE": "Georgia", "AM": "Armenia", "AZ": "Azerbaijan",
            "US": "United States", "CA": "Canada", "MX": "Mexico", "CU": "Cuba", "JM": "Jamaica",
            "HT": "Haiti", "DO": "Dominican Republic", "PR": "Puerto Rico", "BS": "Bahamas", "BB": "Barbados",
            "TT": "Trinidad and Tobago", "GD": "Grenada", "LC": "Saint Lucia", "VC": "Saint Vincent and the Grenadines",
            "AG": "Antigua and Barbuda", "DM": "Dominica", "KN": "Saint Kitts and Nevis", "BZ": "Belize",
            "GT": "Guatemala", "SV": "El Salvador", "HN": "Honduras", "NI": "Nicaragua", "CR": "Costa Rica",
            "PA": "Panama", "BR": "Brazil", "AR": "Argentina", "CL": "Chile", "PE": "Peru", "CO": "Colombia",
            "VE": "Venezuela", "EC": "Ecuador", "BO": "Bolivia", "PY": "Paraguay", "UY": "Uruguay",
            "GY": "Guyana", "SR": "Suriname", "GF": "French Guiana", "AU": "Australia", "NZ": "New Zealand",
            "PG": "Papua New Guinea", "FJ": "Fiji", "SB": "Solomon Islands", "VU": "Vanuatu", "NC": "New Caledonia",
            "PF": "French Polynesia", "WS": "Samoa", "TO": "Tonga", "FM": "Micronesia", "PW": "Palau",
            "MH": "Marshall Islands", "KI": "Kiribati", "TV": "Tuvalu", "NR": "Nauru"
        ]
        
        return countryNames[countryCode] ?? countryCode
    }
    
    /// Get the language name for display purposes when a localized name is found
    func getLocalizedLanguageName(for herb: Herb, userLocation: String, userLanguages: [String]) -> String? {
        // First, try to find a name based on user's location
        if let locationBasedName = getLocationBasedName(for: herb, userLocation: userLocation) {
            // Find the country code for this location
            let location = userLocation.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if let countryCode = locationToCountryCode[location] {
                return getCountryName(from: countryCode)
            }
        }
        
        // Then, try to find a name based on user's languages
        for language in userLanguages {
            let languageLower = language.lowercased()
            
            // Get country codes for this language
            if let countryCodes = languageToCountryCode[languageLower] {
                // Try each country code for this language
                for countryCode in countryCodes {
                    if let localName = herb.localNames[countryCode] {
                        return language.capitalized
                    }
                }
            }
        }
        
        return nil
    }
} 