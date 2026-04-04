# 🕌 Mosque Locator Feature Documentation

## Overview
The Mosque Locator feature allows users to find nearby mosques around their current location and view them on an interactive Google Map with detailed information like address, phone, website, ratings, and more.

## Features

### 1. **Find Nearby Mosques**
- Get a list of mosques within a customizable search radius (1 km - 10 km)
- Display mosques as green markers on Google Maps
- Show user's current location as a blue marker
- Visual search radius circle to understand coverage area

### 2. **Mosque Details**
- Tap on any mosque marker to see detailed information in a bottom sheet
- View mosque name, address, distance, phone number, website, and opening hours
- Display ratings and review count (when available)

### 3. **Quick Actions**
- **Directions**: Opens Google Maps with directions to the mosque
- **Call**: Direct phone dialing to mosque's phone number
- **Website**: Open mosque's website in browser

### 4. **Search Controls**
- Adjustable search radius using slider (1 km - 10 km)
- Manual refresh button to reload nearby mosques
- "My Location" button to recenter map

### 5. **Dual Data Sources**
- **Primary**: Google Places API (if API key configured)
- **Fallback**: Overpass API (Free, OpenStreetMap data)
- Automatic fallback if one source fails

## Architecture

```
features/
├── location/
│   ├── models/
│   │   └── mosque_model.dart           # Mosque data model
│   ├── data/
│   │   └── mosque_repository.dart      # Data fetching logic
│   └── screens/
│       └── mosque_map_screen.dart      # Main map UI
└── masjid/
    └── screens/
        └── masjid_locator_screen.dart  # Wrapper screen
```

## Usage

### From Home Screen
User clicks the "Find Masjid" (মসজিদ খুঁজুন) tile in the Quick Access section → navigates to mosque map

### In main_shell.dart
```dart
case HomeQuickAction.masjid:
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MasjidLocatorScreen(
        language: widget.settings.language,
        locationService: widget.locationService,
        // googleApiKey: 'YOUR_API_KEY', // Optional: for Google Places API
      ),
    ),
  );
  break;
```

## Data Models

### MosqueModel
Contains:
- `id`: Unique identifier
- `name`: Mosque name (Bengali/English)
- `latitude`, `longitude`: GPS coordinates
- `address`: Full address
- `phone`: Phone number
- `website`: Website URL
- `rating`: Google rating (if available)
- `reviewCount`: Number of reviews
- `openingHours`: Operating hours
- `distanceInKm`: Distance from user

## API Integration

### Option 1: Overpass API (Default - Free)
- No API key required
- Uses OpenStreetMap data
- Search radius up to 10 km
- Limits to 50 closest mosques

**Query Format:**
```
[out:json];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:radius,lat,lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:radius,lat,lon);
);
out center;
```

### Option 2: Google Places API (Optional - Enhanced)
- Requires API key configuration
- Real-time data with ratings and reviews
- Higher accuracy for verified places
- Better for reliability

**To enable:**
1. Get Google Maps API Key from Google Cloud Console
2. Enable Places API
3. Update configuration (Android/iOS)
4. Pass API key to MasjidLocatorScreen

## Permissions Required

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby mosques</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to find nearby mosques</string>
```

## Error Handling

1. **Location Permission Denied**: Shows error message, user can retry
2. **Location Service Unavailable**: Displays error with retry button
3. **API Timeout**: Falls back to alternative data source
4. **No Mosques Found**: Shows message that no mosques in radius
5. **Network Error**: Shows error with refresh option

## Localization

Feature supports:
- **Bengali (বাংলা)**: Full UI translation
- **English**: Default language

All text is dynamically converted based on `AppLanguage` setting.

## Performance Considerations

1. **Marker Limit**: Limited to 50 closest mosques for performance
2. **Distance Calculation**: Uses Haversine formula for accuracy
3. **Async Loading**: All API calls are asynchronous
4. **Map Animation**: Smooth camera transitions
5. **Memory**: Circle and Marker collections cleared before reload

## Testing

### Manual Testing Steps
1. Enable location on device
2. Open app and navigate to "Find Masjid"
3. App requests location permission (allow it)
4. Map displays current location with search radius
5. Nearby mosques appear as green markers
6. Tap marker to view details
7. Test action buttons (Directions, Call, Website)
8. Adjust search radius and refresh

### Test Scenarios
- ✅ First location access
- ✅ Multiple searches in same session
- ✅ Change search radius
- ✅ Network failure/timeout
- ✅ Permission denial
- ✅ Language switching (EN/BN)

## Future Enhancements

1. **Prayer Times Integration**: Show prayer times for selected mosque
2. **Favorites**: Save favorite mosques
3. **Reviews**: User ratings and reviews
4. **Mosque Categories**: Filter by mosque type/features
5. **Offline Maps**: Download maps for areas with no internet
6. **Share Location**: Share mosque location with others
7. **Notifications**: Alerts for nearby mosques during prayer times
8. **Photos**: Gallery of mosque photos

## Troubleshooting

### Map not showing
- Check location permissions
- Ensure Google Maps API key (if using Google Maps)
- Verify internet connection
- Restart app

### No mosques found
- Increase search radius
- Check location is correct
- Try different data source (toggle API)

### "Maps API error"
- Verify API key is valid
- Check API key has needed scopes enabled
- Ensure billing is enabled in Google Cloud

### Slow performance
- Reduce search radius
- Check internet connection quality
- Close other apps to free up memory

## References

- [Overpass API Documentation](https://wiki.openstreetmap.org/wiki/Overpass_API)
- [Google Places API](https://developers.google.com/maps/documentation/places/web-service/overview)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)
