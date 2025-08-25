class YonoGreetings {
  static String showGreetings() {
    String greeting() {
      var timeNow = DateTime.now().hour;
      if (timeNow <= 12) {
        return 'อรุณสวัสดิ์';
      } else if ((timeNow > 12) && (timeNow <= 16)) {
        return 'สวัสดีตอนบ่าย';
      } else if ((timeNow > 16) && (timeNow <= 20)) {
        return 'สวัสดีตอนเย็น';
      } else {
        return 'ราตรีสวัสดิ์';
      }
    }

    return greeting();
  }
}
