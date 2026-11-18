class ApiConfig {
  // NGINX on port 80 → uvicorn on :8000 (never bypass NGINX in production)
  static const String baseUrl = 'http://localhost:8000';

  // Named endpoint constants for convenience
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String versionEndpoint = '$baseUrl/version';
}
