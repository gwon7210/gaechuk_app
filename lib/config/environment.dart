enum Environment { dev, prod }

class Env {
  static Environment environment = Environment.dev;

  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        // return 'http://10.0.2.2:3000';
        return 'http://192.168.0.187:3000';
      // return 'http://13.125.244.0:3000';
      case Environment.prod:
        return 'http://13.125.244.0:3000'; // 실제 프로덕션 도메인으로 변경 필요
    }
  }
}
