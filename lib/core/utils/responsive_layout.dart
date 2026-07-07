double adaptivePagePadding(double width) {
  if (width >= 1100) return 32;
  if (width >= 700) return 24;
  return 16;
}

int adaptiveGridColumns(
  double width, {
  int compact = 2,
  int medium = 3,
  int expanded = 4,
}) {
  if (width >= 1100) return expanded;
  if (width >= 700) return medium;
  return compact;
}
