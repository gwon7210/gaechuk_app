enum Environment {
  dev,
  prod,
}

class Env {
  static Environment environment = Environment.dev;

  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://10.0.2.2:3000';
      case Environment.prod:
        return 'https://gaechuk-server.onrender.com'; // 실제 프로덕션 도메인으로 변경 필요
    }
  }
}
