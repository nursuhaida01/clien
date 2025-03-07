enum Size {
  medium, //normal size text
  bold, //only bold text
  boldMedium, //bold with medium
  boldLarge, //bold with large
  extraLarge,
  ultraLarge,   // 🚀 ใหญ่กว่า extraLarge
  megaLarge,    // 🚀 ใหญ่กว่า ultraLarge
  gigaLarge,    // 🚀🚀 ใหญ่สุด
  teraLarge,
  
  normal //extra large
}

enum Align {
  left, //ESC_ALIGN_LEFT
  center, //ESC_ALIGN_CENTER
  right, //ESC_ALIGN_RIGHT
}

extension PrintSize on Size {
  int get val {
    switch (this) {
      case Size.medium:
        return 0;
      case Size.bold:
        return 1;
      case Size.boldMedium:
        return 2;
      case Size.boldLarge:
        return 3;
      case Size.extraLarge:
        return 4;
      case Size.ultraLarge:
        return 5;  // ✅ เพิ่ม ultraLarge
      case Size.megaLarge:
        return 6;  // ✅ เพิ่ม megaLarge
      case Size.gigaLarge:
        return 7;  // ✅ เพิ่ม gigaLarge
      case Size.teraLarge:
        return 8; 
      default:
        return 0;
    }
  }
}

extension PrintAlign on Align {
  int get val {
    switch (this) {
      case Align.left:
        return 0;
      case Align.center:
        return 1;
      case Align.right:
        return 2;
      default:
        return 0;
    }
  }
}
