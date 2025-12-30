pub mod metadata;
pub mod render;
pub mod text;

pub use render::RenderedPage;
pub use render::open;
pub use render::close;
pub use render::render_page;
pub use metadata::get_info;