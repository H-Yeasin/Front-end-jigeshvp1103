class DevAuthSession {
  static const String defaultAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2YTMyMTY5OThjYTFmYmU3ZDNkN2MwNzAiLCJlbWFpbCI6InN0dWRlbnQxQGdtYWlsLmNvbSIsInJvbGUiOiJzdHVkZW50IiwiaWF0IjoxNzgyMzc1NTg2LCJleHAiOjE3ODI5ODAzODZ9.xCLB5nbe7nEUoV_goebu8qhHQiQ1v0kiyW71i73yf0I';

  static String _accessToken = '';

  static String get accessToken => _accessToken;

  static void setAccessToken(String value) {
    _accessToken = value.trim();
  }

  static void clear() {
    _accessToken = '';
  }
}
