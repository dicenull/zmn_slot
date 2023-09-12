enum SlotSymbol {
  zu,
  nn,
  da,
  bar,
  watermelon,
  bell,
  plum,
  cherry,
  replay;

  // r:replay, z:zunda, p:plum, h:hiyoko, f:font(z,n,d), b:bar, c:cherry

  // rzphfrfzphrbpzhrcpzh
  // przhpbrzhpfrfhzpcrhz
  // hprzfhfprzbhpzrchprz
  static List<SlotSymbol> get first => [
        replay,
        watermelon,
        plum,
        bell,
        zu,
        replay,
        zu,
        watermelon,
        plum,
        bell,
        replay,
        bar,
        plum,
        watermelon,
        bell,
        replay,
        cherry,
        plum,
        watermelon,
        bell,
      ];

  static List<SlotSymbol> get second => [
        plum,
        replay,
        watermelon,
        bell,
        plum,
        bar,
        replay,
        watermelon,
        bell,
        plum,
        nn,
        replay,
        nn,
        bell,
        watermelon,
        plum,
        cherry,
        replay,
        bell,
        watermelon,
      ];

  static List<SlotSymbol> get third => [
        bell,
        plum,
        replay,
        watermelon,
        da,
        bell,
        da,
        plum,
        replay,
        watermelon,
        bar,
        bell,
        plum,
        watermelon,
        replay,
        cherry,
        bell,
        plum,
        replay,
        watermelon,
      ];

  int get point => switch (this) {
        bell => 30,
        bar => 50,
        cherry => 3,
        plum => 6,
        replay => 3,
        zu || nn || da => 10,
        watermelon => 15,
      };
}
