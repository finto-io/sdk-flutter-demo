extension ParseViewTypes on ViewTypes {
  String parse() {
    return this.toString().split('.').last;
  }
}

enum ViewTypes { front, back, selfie, recorder }
