// API Service — connects to FastAPI backend when ready
// Currently returns mock data for offline/demo mode

class ApiService {
  static const String _baseUrl = 'https://your-backend-url.com';
  static bool _isOfflineMode = true;

  static bool get isOffline => _isOfflineMode;

  static void setBaseUrl(String url) {
    _baseUrl == url;
    _isOfflineMode = false;
  }

  // Health check
  static Future<bool> ping() async {
    if (_isOfflineMode) return false;
    try {
      // TODO: implement HTTP ping
      return true;
    } catch (_) {
      return false;
    }
  }

  // Send lab result to backend
  static Future<Map<String, dynamic>?> analyzeLabResult(
      Map<String, dynamic> data) async {
    if (_isOfflineMode) return _mockRiskAssessment(data);
    // TODO: implement POST /analyze
    return null;
  }

  // Mock risk assessment (offline AI)
  static Map<String, dynamic> _mockRiskAssessment(Map<String, dynamic> data) {
    final hb = data['hemoglobin'] ?? 12.0;
    final systolic = data['systolic'] ?? 120;

    String risk = 'green';
    List<String> flags = [];

    if (hb < 8.0) {
      risk = 'red';
      flags.add('Severe anemia detected');
    } else if (hb < 11.0) {
      risk = 'yellow';
      flags.add('Mild anemia — increase iron intake');
    }

    if (systolic > 140) {
      risk = 'red';
      flags.add('Hypertension — seek medical attention');
    } else if (systolic > 130) {
      if (risk != 'red') risk = 'yellow';
      flags.add('Elevated blood pressure — monitor closely');
    }

    return {
      'riskLevel': risk,
      'flags': flags,
      'recommendation': flags.isEmpty
          ? 'All values within normal range'
          : flags.join('. '),
    };
  }
}
