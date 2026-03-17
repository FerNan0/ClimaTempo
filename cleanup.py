#!/usr/bin/env python3
import os

base = '/Users/ferskt/Desktop/Eng-Software-USP/TCC/ClimaAgora/ClimaAgora'
files_to_delete = [
    'WeatherViewModel.swift',
    'ContentView.swift',
    'SearchView.swift',
    'SettingsView.swift',
    'ActivityRecommendationView.swift',
    'AIRecommendationView.swift',
    'AnimatedWeatherIcon.swift',
    'ForecastCard.swift',
    'ShareSheet.swift',
    'WeatherService.swift',
    'IAService.swift',
    'ActivityRecommendationService.swift',
    'LocationManager.swift',
    'NotificationManager.swift',
    'HapticManager.swift',
    'ShareManager.swift',
    'FavoriteCitiesManager.swift',
    'SearchHistoryManager.swift',
    'WantToVisitManager.swift',
    'AccessibilityHelper.swift',
    'ClimaWeatherWidget.swift',
    'Item.swift',
    'BuildConfiguration.xcconfig',
    'ContentViewSimplified.swift',
]

deleted = 0
for f in files_to_delete:
    path = os.path.join(base, f)
    if os.path.exists(path):
        os.remove(path)
        deleted += 1

# Write result to a marker file
with open(os.path.join(base, '_cleanup_result.txt'), 'w') as out:
    out.write(f'Deleted {deleted} files\n')
    # List remaining files
    for item in sorted(os.listdir(base)):
        out.write(f'  {item}\n')
