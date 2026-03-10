use std::fmt;

#[derive(Debug, Clone)]
pub enum ParseError {
    EmptyInput,
    InvalidToken(String),
    InvalidRange(String),
    InvalidNumber(String),
    PageOutOfBounds(u32, u32),
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ParseError::EmptyInput => write!(f, "Input cannot be empty"),
            ParseError::InvalidToken(t) => write!(f, "Invalid token: {}", t),
            ParseError::InvalidRange(r) => write!(f, "Invalid range: {}", r),
            ParseError::InvalidNumber(n) => write!(f, "Invalid number: {}", n),
            ParseError::PageOutOfBounds(p, max) => {
                write!(f, "Page {} exceeds document length {}", p, max)
            }
        }
    }
}

impl std::error::Error for ParseError {}
