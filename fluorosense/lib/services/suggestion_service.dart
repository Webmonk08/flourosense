/// Provides health suggestions based on dental fluorosis classification results.
class SuggestionService {
  /// Returns a suggestion map for a single analysis result.
  /// Keys: 'severity', 'color', 'icon', 'title', 'description', 'tips'
  static Map<String, dynamic> getSuggestion(String classification) {
    switch (classification.toLowerCase().trim()) {
      case 'no fluorosis':
        return {
          'severity': 'none',
          'color': 0xFF4CAF50, // Green
          'icon': 'check_circle',
          'title': 'Healthy Teeth',
          'description':
              'Great news! No signs of dental fluorosis were detected. Your dental enamel appears to be in good condition.',
          'tips': [
            'Continue brushing twice daily with fluoride toothpaste.',
            'Visit your dentist for regular check-ups every 6 months.',
            'Maintain a balanced diet for strong teeth and gums.',
            'Monitor your water source for safe fluoride levels (< 1.5 ppm).',
          ],
        };
      case 'mild':
        return {
          'severity': 'mild',
          'color': 0xFFFFC107, // Amber
          'icon': 'info',
          'title': 'Mild Fluorosis Detected',
          'description':
              'Mild dental fluorosis has been detected. This typically presents as faint white streaks or spots on the teeth. It is mostly a cosmetic concern and does not affect tooth function.',
          'tips': [
            'Use toothpaste with controlled fluoride levels (children: < 1000 ppm).',
            'Avoid swallowing toothpaste, especially for children under 6.',
            'Consider switching to an RO or filtered water source if using well/ground water.',
            'Get your drinking water tested for fluoride concentration.',
            'Consult a dentist for cosmetic options like microabrasion if needed.',
          ],
        };
      case 'moderate':
        return {
          'severity': 'moderate',
          'color': 0xFFFF9800, // Orange
          'icon': 'warning',
          'title': 'Moderate Fluorosis Detected',
          'description':
              'Moderate dental fluorosis has been detected. This typically shows as more prominent white or brownish discoloration on the teeth. Dental consultation is recommended.',
          'tips': [
            'Consult a dentist promptly for a detailed clinical assessment.',
            'Switch to low-fluoride or non-fluoride toothpaste immediately.',
            'Use RO-purified or bottled water with safe fluoride levels.',
            'Avoid fluoride supplements unless prescribed by a doctor.',
            'Consider dental treatments like bonding or veneers for affected teeth.',
            'Increase calcium and vitamin D intake to support enamel health.',
          ],
        };
      case 'severe':
        return {
          'severity': 'severe',
          'color': 0xFFF44336, // Red
          'icon': 'error',
          'title': 'Severe Fluorosis Detected',
          'description':
              'Severe dental fluorosis has been detected. This involves significant enamel damage with brown staining, pitting, and possible structural weakness. Immediate professional care is strongly recommended.',
          'tips': [
            'Seek immediate dental consultation for treatment planning.',
            'Stop using fluoridated toothpaste and switch to a non-fluoride alternative.',
            'Install an RO water purification system or use verified safe water.',
            'Get a comprehensive fluoride exposure assessment from a specialist.',
            'Explore restorative dental treatments (crowns, veneers, composites).',
            'Report high fluoride levels in your water source to local health authorities.',
            'Ensure children in the household are also assessed for fluorosis.',
          ],
        };
      default:
        return {
          'severity': 'unknown',
          'color': 0xFF9E9E9E, // Grey
          'icon': 'help',
          'title': 'Analysis Result',
          'description': 'Classification: $classification. Please consult a dentist for further evaluation.',
          'tips': [
            'Consult a dental professional for a thorough examination.',
            'Maintain good oral hygiene practices.',
          ],
        };
    }
  }

  /// Generates an overall health summary based on the user's report history.
  /// Returns a map with: 'overallStatus', 'color', 'summary', 'trend', 'recommendations'
  static Map<String, dynamic> getOverallSummary(List<dynamic> reports) {
    if (reports.isEmpty) {
      return {
        'overallStatus': 'No Data',
        'color': 0xFF9E9E9E,
        'summary': 'No analysis history available yet. Submit your first dental analysis to get personalized insights.',
        'trend': 'neutral',
        'recommendations': <String>[],
      };
    }

    // Count classifications
    int noFluorosis = 0, mild = 0, moderate = 0, severe = 0;
    for (final report in reports) {
      final classification = (report['classification'] ?? '').toString().toLowerCase().trim();
      switch (classification) {
        case 'no fluorosis':
          noFluorosis++;
          break;
        case 'mild':
          mild++;
          break;
        case 'moderate':
          moderate++;
          break;
        case 'severe':
          severe++;
          break;
      }
    }

    final total = reports.length;
    final healthyPercent = (noFluorosis / total * 100).round();

    // Determine overall status based on worst frequent result
    String overallStatus;
    int color;
    String summary;
    List<String> recommendations = [];

    if (severe > 0) {
      overallStatus = 'Needs Attention';
      color = 0xFFF44336;
      summary = '$severe out of $total analyses detected severe fluorosis. Immediate professional dental care is strongly recommended.';
      recommendations = [
        'Schedule a dental appointment as soon as possible.',
        'Eliminate high-fluoride water sources immediately.',
        'Consult a public health specialist about fluoride exposure.',
        'Regular monitoring with follow-up analyses is essential.',
      ];
    } else if (moderate > 0) {
      overallStatus = 'Moderate Risk';
      color = 0xFFFF9800;
      summary = '$moderate out of $total analyses showed moderate fluorosis. Dental consultation is recommended to prevent progression.';
      recommendations = [
        'Visit a dentist for a clinical assessment.',
        'Review and reduce fluoride exposure sources.',
        'Switch to low-fluoride toothpaste.',
        'Test your drinking water for fluoride levels.',
      ];
    } else if (mild > 0) {
      overallStatus = 'Low Risk';
      color = 0xFFFFC107;
      summary = '$mild out of $total analyses showed mild fluorosis. This is mostly cosmetic, but preventive measures are advised.';
      recommendations = [
        'Monitor fluoride intake from water and toothpaste.',
        'Use age-appropriate fluoride toothpaste.',
        'Get regular dental check-ups every 6 months.',
      ];
    } else {
      overallStatus = 'Healthy';
      color = 0xFF4CAF50;
      summary = 'All $total analyses show healthy teeth with no fluorosis. Keep up the great oral hygiene!';
      recommendations = [
        'Continue your current dental care routine.',
        'Regular check-ups every 6 months.',
        'Maintain a balanced diet for healthy teeth.',
      ];
    }

    // Determine trend from last 3 reports
    String trend = 'stable';
    if (reports.length >= 2) {
      // Sort by timestamp (most recent first)
      final sorted = List<dynamic>.from(reports);
      sorted.sort((a, b) {
        final ta = DateTime.tryParse(a['timestamp']?.toString() ?? '') ?? DateTime(2000);
        final tb = DateTime.tryParse(b['timestamp']?.toString() ?? '') ?? DateTime(2000);
        return tb.compareTo(ta);
      });

      final severityMap = {'no fluorosis': 0, 'mild': 1, 'moderate': 2, 'severe': 3};
      final recentSeverity = severityMap[sorted.first['classification']?.toString().toLowerCase().trim()] ?? 0;
      final olderSeverity = severityMap[sorted.last['classification']?.toString().toLowerCase().trim()] ?? 0;

      if (recentSeverity < olderSeverity) {
        trend = 'improving';
      } else if (recentSeverity > olderSeverity) {
        trend = 'worsening';
      }
    }

    return {
      'overallStatus': overallStatus,
      'color': color,
      'summary': summary,
      'trend': trend,
      'recommendations': recommendations,
      'stats': {
        'total': total,
        'noFluorosis': noFluorosis,
        'mild': mild,
        'moderate': moderate,
        'severe': severe,
        'healthyPercent': healthyPercent,
      },
    };
  }
}
