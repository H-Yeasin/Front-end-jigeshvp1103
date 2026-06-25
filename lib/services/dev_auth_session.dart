class DevAuthSession {
  static const String defaultAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2YTMyMTY5OThjYTFmYmU3ZDNkN2MwNzAiLCJlbWFpbCI6InN0dWRlbnQxQGdtYWlsLmNvbSIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzgyMjczMDU4LCJleHAiOjE3ODI4Nzc4NTh9.ssf958MMvRJPaAA1qb3LijuFFg26lB1ktI_VHMmx8kY';

  static String _accessToken = '';

  static String get accessToken => _accessToken;

  static void setAccessToken(String value) {
    _accessToken = value.trim();
  }

  static void clear() {
    _accessToken = '';
  }
}
