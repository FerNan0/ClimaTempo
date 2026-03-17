#!/usr/bin/env python3
import shutil, os

base = '/Users/ferskt/Desktop/Eng-Software-USP/TCC/ClimaAgora/ClimaAgora'

# Create all target folders
for d in ['ViewModels','Views/Screens','Views/Components','Services','Managers','Helpers','Widgets','Resources','Models']:
    os.makedirs(os.path.join(base, d), exist_ok=True)

# Define all moves: source (relative to base) -> destination (relative to base)
moves = {
    'WeatherViewModel.swift': 'ViewModels/WeatherViewModel.swift',
    'ContentView.swift': 'Views/Screens/ContentView.swift',
    'ContentViewSimplified.swift': 'Views/Screens/ContentViewSimplified.swift',
    'SearchView.swift': 'Views/Screens/SearchView.swift',
    'SettingsView.swift': 'Views/Screens/SettingsView.swift',
    'ActivityRecommendationView.swift': 'Views/Screens/ActivityRecommendationView.swift',
    'AIRecommendationView.swift': 'Views/Screens/AIRecommendationView.swift',
    'AnimatedWeatherIcon.swift': 'Views/Components/AnimatedWeatherIcon.swift',
    'ForecastCard.swift': 'Views/Components/ForecastCard.swift',
    'ShareSheet.swift': 'Views/Components/ShareSheet.swift',
    'WeatherService.swift': 'Services/WeatherService.swift',
    'IAService.swift': 'Services/IAService.swift',
    'ActivityRecommendationService.swift': 'Services/ActivityRecommendationService.swift',
    'LocationManager.swift': 'Managers/LocationManager.swift',
    'NotificationManager.swift': 'Managers/NotificationManager.swift',
    'HapticManager.swift': 'Managers/HapticManager.swift',
    'ShareManager.swift': 'Managers/ShareManager.swift',
    'FavoriteCitiesManager.swift': 'Managers/FavoriteCitiesManager.swift',
    'SearchHistoryManager.swift': 'Managers/SearchHistoryManager.swift',
    'WantToVisitManager.swift': 'Managers/WantToVisitManager.swift',
    'AccessibilityHelper.swift': 'Helpers/AccessibilityHelper.swift',
    'Item.swift': 'Models/Item.swift',
    'ClimaWeatherWidget.swift': 'Widgets/ClimaWeatherWidget.swift',
    'BuildConfiguration.xcconfig': 'Resources/BuildConfiguration.xcconfig',
}

moved = 0
for src_name, dst_rel in moves.items():
    src = os.path.join(base, src_name)
    dst = os.path.join(base, dst_rel)
    if os.path.exists(src):
        # Remove destination if it already exists (from previous partial attempt)
        if os.path.exists(dst):
            os.remove(dst)
        shutil.move(src, dst)
        moved += 1
        print(f'  OK {src_name} -> {dst_rel}')
    else:
        print(f'  SKIP {src_name} (not found at root)')

print(f'\nMoved {moved} files. DONE.')
