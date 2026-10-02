sealed class PageSelectionItem {
  const PageSelectionItem();
}

final class PageSelectionPage extends PageSelectionItem {
  const PageSelectionPage(this.page);

  final int page;
}

final class PageSelectionRange extends PageSelectionItem {
  const PageSelectionRange(this.start, this.end);

  final int start;
  final int end;
}

final class PageSelectionOpenStart extends PageSelectionItem {
  const PageSelectionOpenStart(this.end);

  final int end;
}

final class PageSelectionOpenEnd extends PageSelectionItem {
  const PageSelectionOpenEnd(this.start);

  final int start;
}

final class PageSelectionLast extends PageSelectionItem {
  const PageSelectionLast();
}

final class PageSelectionLastMinus extends PageSelectionItem {
  const PageSelectionLastMinus(this.amount);

  final int amount;
}

final class PageSelectionOdd extends PageSelectionItem {
  const PageSelectionOdd();
}

final class PageSelectionEven extends PageSelectionItem {
  const PageSelectionEven();
}