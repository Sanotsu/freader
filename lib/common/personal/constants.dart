class GlobalConstants {
  static String pexelsAuthorization =
      "563492ad6f917000010000014ea60eda20074aa98a17fdc4e162ad15";

  static String baiduFanyiApiAppId = "20220708001267549";
  static String baiduFanyiApiSecretKey = "JXwJEoYMwNEmFUidryW0";

  /// 记录登入账号、状态的字符串key
  static String loginState = "loginState";
  static String loginAccount = "loginAccount";

  // 安卓中图片的地址（没有找到工具获取该地址，但需要用到，尽量别用），也别在 DCIM 路径下创建了
  static String androidPicturesPath = "/storage/emulated/0/Pictures/";
}
