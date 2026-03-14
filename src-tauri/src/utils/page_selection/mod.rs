pub mod error;
pub mod parser;
pub mod selection;

#[allow(unused_imports)]
pub use error::ParseError;
pub use parser::PageSelectionParser;
#[allow(unused_imports)]
pub use selection::{PageSelection, SelectionItem};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_end_to_end_selection() {
        let input = "1, 3-5, odd, last";
        let selection = PageSelectionParser::parse(input).unwrap();
        let pages = selection.resolve(6).unwrap();

        // 1: [1]
        // 3-5: [3, 4, 5]
        // odd (1-6): [1, 3, 5]
        // last (6): [6]
        // Combined: [1, 3, 4, 5, 1, 3, 5, 6]
        assert_eq!(pages, vec![1, 3, 4, 5, 1, 3, 5, 6]);
    }

    #[test]
    fn test_complex_end_to_end() {
        let input = "even, -2, 5-, last-1";
        let selection = PageSelectionParser::parse(input).unwrap();
        let pages = selection.resolve(6).unwrap();

        // even (1-6): [2, 4, 6]
        // -2: [1, 2]
        // 5-: [5, 6]
        // last-1 (6-1): [5]
        // Combined: [2, 4, 6, 1, 2, 5, 6, 5]
        assert_eq!(pages, vec![2, 4, 6, 1, 2, 5, 6, 5]);
    }

    #[test]
    fn test_error_propagation() {
        // Invalid parsing
        let input = "1, invalid";
        let result = PageSelectionParser::parse(input);
        assert!(matches!(result, Err(ParseError::InvalidToken(_))));

        // Out of bounds during resolution
        let input = "1, 10";
        let selection = PageSelectionParser::parse(input).unwrap();
        let result = selection.resolve(5);
        assert!(matches!(result, Err(ParseError::PageOutOfBounds(10, 5))));
    }

    #[test]
    fn test_resolve_groups_end_to_end() {
        let input = "1, 3-5, odd, last";
        let selection = PageSelectionParser::parse(input).unwrap();
        let groups = selection.resolve_groups(6).unwrap();

        // 1: [1]
        // 3-5: [3, 4, 5]
        // odd (1-6): [1, 3, 5]
        // last (6): [6]
        assert_eq!(groups.len(), 4);
        assert_eq!(groups[0], vec![1]);
        assert_eq!(groups[1], vec![3, 4, 5]);
        assert_eq!(groups[2], vec![1, 3, 5]);
        assert_eq!(groups[3], vec![6]);
    }

    #[test]
    fn test_resolve_groups_error() {
        let input = "1, 10, 3";
        let selection = PageSelectionParser::parse(input).unwrap();
        let result = selection.resolve_groups(5);
        assert!(matches!(result, Err(ParseError::PageOutOfBounds(10, 5))));
    }
}
