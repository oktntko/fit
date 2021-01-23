use crate::ui::common::Screen;
use log::debug;

pub struct Status<'a> {
  status: &'a str,
}

impl<'a> Status<'a> {
  pub fn new() -> Status<'a> {
    Status { status: "good" }
  }
}

impl<'a, B> Screen<B> for Status<'a>
where
  B: tui::backend::Backend,
{
  fn draw(&mut self, f: &mut tui::Frame<B>, area: tui::layout::Rect) {
    debug!("area {:?}", area);
  }
  fn reload(&mut self) {}
  fn on_key_event(&mut self, key: termion::event::Key) {
    debug!("key {:?}", key);
  }
}
