use crate::utils::page_selection::error::ParseError;
use crate::utils::page_selection::selection::{PageSelection, SelectionItem};

pub struct PageSelectionParser;

impl PageSelectionParser {
    pub fn parse(input: &str) -> Result<PageSelection, ParseError> {
        let input = input.trim();

        if input.is_empty() {
            return Err(ParseError::EmptyInput);
        }

        let mut items = Vec::new();

        for token in input.split(',') {
            let token = token.trim();

            if token.eq_ignore_ascii_case("odd") {
                items.push(SelectionItem::Odd);
                continue;
            }

            if token.eq_ignore_ascii_case("even") {
                items.push(SelectionItem::Even);
                continue;
            }

            if token.eq_ignore_ascii_case("last") {
                items.push(SelectionItem::Last);
                continue;
            }

            if token.starts_with("last-") {
                let num = token.trim_start_matches("last-");
                let n: u32 = num
                    .parse()
                    .map_err(|_| ParseError::InvalidNumber(num.to_string()))?;
                items.push(SelectionItem::LastMinus(n));
                continue;
            }

            if token.contains('-') {
                let parts: Vec<&str> = token.split('-').collect();

                if parts.len() != 2 {
                    return Err(ParseError::InvalidRange(token.to_string()));
                }

                let start = parts[0].trim();
                let end = parts[1].trim();

                if start.is_empty() {
                    let e: u32 = end
                        .parse()
                        .map_err(|_| ParseError::InvalidNumber(end.to_string()))?;
                    items.push(SelectionItem::OpenStart(e));
                    continue;
                }

                if end.is_empty() {
                    let s: u32 = start
                        .parse()
                        .map_err(|_| ParseError::InvalidNumber(start.to_string()))?;
                    items.push(SelectionItem::OpenEnd(s));
                    continue;
                }

                let s: u32 = start
                    .parse()
                    .map_err(|_| ParseError::InvalidNumber(start.to_string()))?;

                let e: u32 = end
                    .parse()
                    .map_err(|_| ParseError::InvalidNumber(end.to_string()))?;

                items.push(SelectionItem::Range(s, e));
                continue;
            }

            if let Ok(page) = token.parse::<u32>() {
                items.push(SelectionItem::Page(page));
                continue;
            }

            return Err(ParseError::InvalidToken(token.to_string()));
        }

        Ok(PageSelection::new(items))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_single_pages() {
        let selection = PageSelectionParser::parse("1").unwrap();
        assert_eq!(selection.items.len(), 1);
        match &selection.items[0] {
            SelectionItem::Page(1) => (),
            _ => panic!("Expected Page(1)"),
        }

        let selection = PageSelectionParser::parse(" 10 ").unwrap();
        assert_eq!(selection.items.len(), 1);
        match &selection.items[0] {
            SelectionItem::Page(10) => (),
            _ => panic!("Expected Page(10)"),
        }
    }

    #[test]
    fn test_parse_ranges() {
        let selection = PageSelectionParser::parse("1-5").unwrap();
        assert_eq!(selection.items.len(), 1);
        match &selection.items[0] {
            SelectionItem::Range(1, 5) => (),
            _ => panic!("Expected Range(1, 5)"),
        }

        let selection = PageSelectionParser::parse("5-1").unwrap();
        assert_eq!(selection.items.len(), 1);
        match &selection.items[0] {
            SelectionItem::Range(5, 1) => (),
            _ => panic!("Expected Range(5, 1)"),
        }
    }

    #[test]
    fn test_parse_open_ranges() {
        let selection = PageSelectionParser::parse("-5").unwrap();
        assert_eq!(selection.items.len(), 1);
        match &selection.items[0] {
            SelectionItem::OpenStart(5) => (),
            _ => panic!("Expected OpenStart(5)"),
        }

        let selection = PageSelectionParser::parse("5-").unwrap();
        assert_eq!(selection.items.len(), 1);
        match &selection.items[0] {
            SelectionItem::OpenEnd(5) => (),
            _ => panic!("Expected OpenEnd(5)"),
        }
    }

    #[test]
    fn test_parse_special_tokens() {
        let selection = PageSelectionParser::parse("odd, even, last, last-3").unwrap();
        assert_eq!(selection.items.len(), 4);
        match &selection.items[0] {
            SelectionItem::Odd => (),
            _ => panic!("Expected Odd"),
        }
        match &selection.items[1] {
            SelectionItem::Even => (),
            _ => panic!("Expected Even"),
        }
        match &selection.items[2] {
            SelectionItem::Last => (),
            _ => panic!("Expected Last"),
        }
        match &selection.items[3] {
            SelectionItem::LastMinus(3) => (),
            _ => panic!("Expected LastMinus(3)"),
        }
    }

    #[test]
    fn test_parse_complex_list() {
        let selection = PageSelectionParser::parse("1, 3-5, -2, 8-, last").unwrap();
        assert_eq!(selection.items.len(), 5);
    }

    #[test]
    fn test_parse_errors() {
        assert!(matches!(
            PageSelectionParser::parse(""),
            Err(ParseError::EmptyInput)
        ));
        assert!(matches!(
            PageSelectionParser::parse("   "),
            Err(ParseError::EmptyInput)
        ));
        assert!(matches!(
            PageSelectionParser::parse("abc"),
            Err(ParseError::InvalidToken(_))
        ));
        assert!(matches!(
            PageSelectionParser::parse("1-2-3"),
            Err(ParseError::InvalidRange(_))
        ));
        assert!(matches!(
            PageSelectionParser::parse("1-a"),
            Err(ParseError::InvalidNumber(_))
        ));
        assert!(matches!(
            PageSelectionParser::parse("a-2"),
            Err(ParseError::InvalidNumber(_))
        ));
        assert!(matches!(
            PageSelectionParser::parse("last-x"),
            Err(ParseError::InvalidNumber(_))
        ));
    }

    #[test]
    fn test_parse_case_insensitivity() {
        let selection = PageSelectionParser::parse("ODD, Even, LAST, last-1").unwrap();
        assert!(matches!(selection.items[0], SelectionItem::Odd));
        assert!(matches!(selection.items[1], SelectionItem::Even));
        assert!(matches!(selection.items[2], SelectionItem::Last));
        assert!(matches!(selection.items[3], SelectionItem::LastMinus(1)));
    }
}
