/// 信息太长,分段打印
// ignore_for_file: avoid_print

void cusPrintAll(String msg) {
  //因为String的length是字符数量不是字节数量所以为了防止中文字符过多，
  //  把4*1024的MAX字节打印长度改为1000字符数
  int maxStrLength = 1000;
  //大于1000时
  while (msg.length > maxStrLength) {
    print(msg.substring(0, maxStrLength));
    msg = msg.substring(maxStrLength);
  }
  //剩余部分
  print(msg);
}
