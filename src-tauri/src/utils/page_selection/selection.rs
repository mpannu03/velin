use crate::utils::page_selection::error::ParseError;

#[derive(Debug, Clone)]
pub enum SelectionItem {
    Page(u32),
    Range(u32, u32),
    OpenStart(u32),
    OpenEnd(u32),
    Last,
    LastMinus(u32),
    Odd,
    Even,
}

#[derive(Debug, Clone)]
pub struct PageSelection {
    pub items: Vec<SelectionItem>,
}

impl PageSelection {
    pub fn new(items: Vec<SelectionItem>) -> Self {
        Self { items }
    }

    pub fn resolve(&self, total_pages: u32) -> Result<Vec<u32>, ParseError> {
        let mut result = Vec::new();

        for item in &self.items {
            match item {
                SelectionItem::Page(p) => {
                    if *p > total_pages {
                        return Err(ParseError::PageOutOfBounds(*p, total_pages));
                    }
                    result.push(*p);
                }

                SelectionItem::Range(start, end) => {
                    if *start <= *end {
                        for p in *start..=*end {
                            if p > total_pages {
                                return Err(ParseError::PageOutOfBounds(p, total_pages));
                            }
                            result.push(p);
                        }
                    } else {
                        for p in (*end..=*start).rev() {
                            if p > total_pages {
                                return Err(ParseError::PageOutOfBounds(p, total_pages));
                            }
                            result.push(p);
                        }
                    }
                }

                SelectionItem::OpenStart(end) => {
                    for p in 1..=*end {
                        if p > total_pages {
                            return Err(ParseError::PageOutOfBounds(p, total_pages));
                        }
                        result.push(p);
                    }
                }

                SelectionItem::OpenEnd(start) => {
                    for p in *start..=total_pages {
                        result.push(p);
                    }
                }

                SelectionItem::Last => {
                    result.push(total_pages);
                }

                SelectionItem::LastMinus(n) => {
                    let page = total_pages.saturating_sub(*n);
                    result.push(page);
                }

                SelectionItem::Odd => {
                    for p in 1..=total_pages {
                        if p % 2 == 1 {
                            result.push(p);
                        }
                    }
                }

                SelectionItem::Even => {
                    for p in 1..=total_pages {
                        if p % 2 == 0 {
                            result.push(p);
                        }
                    }
                }
            }
        }

        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_resolve_single_page() {
        let selection = PageSelection::new(vec![SelectionItem::Page(3)]);
        let result = selection.resolve(10).unwrap();
        assert_eq!(result, vec![3]);
    }

    #[test]
    fn test_resolve_range() {
        let selection = PageSelection::new(vec![SelectionItem::Range(1, 3)]);
        let result = selection.resolve(10).unwrap();
        assert_eq!(result, vec![1, 2, 3]);

        let selection = PageSelection::new(vec![SelectionItem::Range(3, 1)]);
        let result = selection.resolve(10).unwrap();
        assert_eq!(result, vec![3, 2, 1]);
    }

    #[test]
    fn test_resolve_open_ranges() {
        let selection = PageSelection::new(vec![SelectionItem::OpenStart(3)]);
        let result = selection.resolve(10).unwrap();
        assert_eq!(result, vec![1, 2, 3]);

        let selection = PageSelection::new(vec![SelectionItem::OpenEnd(8)]);
        let result = selection.resolve(10).unwrap();
        assert_eq!(result, vec![8, 9, 10]);
    }

    #[test]
    fn test_resolve_special_tokens() {
        let selection = PageSelection::new(vec![
            SelectionItem::Odd,
            SelectionItem::Even,
            SelectionItem::Last,
            SelectionItem::LastMinus(1),
        ]);
        let result = selection.resolve(4).unwrap();
        // Odd: 1, 3
        // Even: 2, 4
        // Last: 4
        // LastMinus(1): 3
        assert_eq!(result, vec![1, 3, 2, 4, 4, 3]);
    }

    #[test]
    fn test_resolve_out_of_bounds() {
        let selection = PageSelection::new(vec![SelectionItem::Page(11)]);
        let result = selection.resolve(10);
        assert!(matches!(result, Err(ParseError::PageOutOfBounds(11, 10))));

        let selection = PageSelection::new(vec![SelectionItem::Range(1, 11)]);
        let result = selection.resolve(10);
        assert!(matches!(result, Err(ParseError::PageOutOfBounds(11, 10))));

        let selection = PageSelection::new(vec![SelectionItem::OpenStart(11)]);
        let result = selection.resolve(10);
        assert!(matches!(result, Err(ParseError::PageOutOfBounds(11, 10))));
    }

    #[test]
    fn test_resolve_complex_selection() {
        let selection = PageSelection::new(vec![
            SelectionItem::Page(1),
            SelectionItem::Range(3, 4),
            SelectionItem::Last,
        ]);
        let result = selection.resolve(5).unwrap();
        assert_eq!(result, vec![1, 3, 4, 5]);
    }

    #[test]
    fn test_resolve_empty_selection() {
        let selection = PageSelection::new(vec![]);
        let result = selection.resolve(10).unwrap();
        assert!(result.is_empty());
    }
}
